#!/usr/bin/env node
// Applier for agent task -04N-* (exhibitor translation backfill).
//
// Reads a per-row translation payload of shape
//   [{ "id": "...", "en": "...", "sv": "..." }, ...]
// from a file passed on the command line (default
// `scripts/translations/exhibitors-04a.json`) and rewrites the
// matching exhibitor rows in `supabase/seed/seed.sql` and
// `web/data/catalog.json` so that the description JSONB carries the
// translated `{ en, sv }`.
//
// Idempotent: rows whose description already matches the payload are
// left untouched. Rows in the payload that are not found in the seed
// raise an error (no silent partial application).
//
// Reuses the row-walking helpers from
// `scripts/wrap_exhibitor_descriptions.mjs`.
//
// Usage:
//   node scripts/apply_exhibitor_translations.mjs \
//       [scripts/translations/exhibitors-04a.json]

import { readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const REPO = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
);
const SEED_PATH = path.join(REPO, "supabase/seed/seed.sql");
const CATALOG_PATH = path.join(REPO, "web/data/catalog.json");
const DEFAULT_PAYLOAD = path.join(
  REPO,
  "scripts/translations/exhibitors-04a.json",
);

const INSERT_HEADER =
  "insert into public.exhibitors (id, event_id, name, booth, description, website, logo) values\n";
const ON_CONFLICT_LINE = "on conflict (id) do update set";

function findMatchingClose(text, openIdx) {
  let depth = 1;
  let i = openIdx + 1;
  while (i < text.length) {
    const c = text[i];
    if (c === "'") {
      i = skipString(text, i);
      continue;
    }
    if (c === "(") {
      depth++;
      i++;
      continue;
    }
    if (c === ")") {
      depth--;
      if (depth === 0) return i;
      i++;
      continue;
    }
    i++;
  }
  throw new Error(
    `unterminated paren at offset ${openIdx}: ${text.slice(openIdx, openIdx + 80)}`,
  );
}

function skipString(text, i) {
  if (text[i] !== "'") {
    throw new Error(`skipString called at non-quote at offset ${i}`);
  }
  i++;
  while (i < text.length) {
    if (text[i] === "'") {
      if (text[i + 1] === "'") {
        i += 2;
        continue;
      }
      return i + 1;
    }
    i++;
  }
  throw new Error(`unterminated string starting near offset ${i}`);
}

function splitTopLevelByComma(text) {
  const parts = [];
  let i = 0;
  let start = 0;
  let depth = 0;
  while (i < text.length) {
    const c = text[i];
    if (c === "'") {
      i = skipString(text, i);
      continue;
    }
    if (c === "(") {
      depth++;
      i++;
      continue;
    }
    if (c === ")") {
      depth--;
      i++;
      continue;
    }
    if (c === "," && depth === 0) {
      parts.push(text.slice(start, i));
      start = i + 1;
    }
    i++;
  }
  parts.push(text.slice(start));
  return parts;
}

function sqlQuote(s) {
  return "'" + String(s).replace(/'/g, "''") + "'";
}

function rewriteSeed(seed, byId) {
  const headerIdx = seed.indexOf(INSERT_HEADER);
  if (headerIdx < 0) {
    throw new Error("exhibitors INSERT header not found in seed.sql");
  }
  const bodyStart = headerIdx + INSERT_HEADER.length;
  const onConflictIdx = seed.indexOf(ON_CONFLICT_LINE, bodyStart);
  if (onConflictIdx < 0) {
    throw new Error("on-conflict clause for exhibitors not found");
  }
  const before = seed.slice(0, bodyStart);
  const body = seed.slice(bodyStart, onConflictIdx);
  const after = seed.slice(onConflictIdx);

  let out = "";
  let i = 0;
  let rowCount = 0;
  let updated = 0;
  let unchanged = 0;
  const seen = new Set();
  while (i < body.length) {
    const c = body[i];
    if (c === "(") {
      const closeIdx = findMatchingClose(body, i);
      const inner = body.slice(i + 1, closeIdx);
      const fields = splitTopLevelByComma(inner);
      if (fields.length !== 7) {
        throw new Error(
          `expected 7 fields per exhibitor row, got ${fields.length}: ${inner.slice(0, 200)}`,
        );
      }
      const idLiteral = fields[0].trim();
      // id is a single-quoted literal like 'estro-2026-exhibitor-...'
      if (!idLiteral.startsWith("'") || !idLiteral.endsWith("'")) {
        throw new Error(`unexpected id token: ${idLiteral.slice(0, 80)}`);
      }
      const id = idLiteral.slice(1, -1).replace(/''/g, "'");
      const tr = byId.get(id);
      if (tr) {
        seen.add(id);
        const wrapped = `jsonb_build_object('en', ${sqlQuote(tr.en)}, 'sv', ${sqlQuote(tr.sv)})`;
        const desc = fields[4];
        const leading = desc.match(/^\s*/)[0];
        const trailing = desc.match(/\s*$/)[0];
        const newField = leading + wrapped + trailing;
        if (newField !== desc) {
          fields[4] = newField;
          updated++;
        } else {
          unchanged++;
        }
        out += "(" + fields.join(",") + ")";
      } else {
        out += "(" + inner + ")";
      }
      i = closeIdx + 1;
      rowCount++;
    } else {
      out += c;
      i++;
    }
  }
  const missing = [];
  for (const id of byId.keys()) if (!seen.has(id)) missing.push(id);
  if (missing.length) {
    throw new Error(
      `payload IDs not found in seed.sql exhibitors: ${missing.slice(0, 10).join(", ")}${missing.length > 10 ? "…" : ""}`,
    );
  }
  return {
    text: before + out + after,
    stats: { rowCount, updated, unchanged },
  };
}

function rewriteCatalog(catalogText, byId) {
  const catalog = JSON.parse(catalogText);
  if (!Array.isArray(catalog.exhibitors)) {
    throw new Error("catalog.json has no exhibitors array");
  }
  let updated = 0;
  let unchanged = 0;
  const seen = new Set();
  for (const ex of catalog.exhibitors) {
    const tr = byId.get(ex.id);
    if (!tr) continue;
    seen.add(ex.id);
    const next = { en: tr.en, sv: tr.sv };
    const cur = ex.description;
    if (
      cur &&
      typeof cur === "object" &&
      cur.en === next.en &&
      cur.sv === next.sv
    ) {
      unchanged++;
      continue;
    }
    ex.description = next;
    updated++;
  }
  const missing = [];
  for (const id of byId.keys()) if (!seen.has(id)) missing.push(id);
  if (missing.length) {
    throw new Error(
      `payload IDs not found in catalog.json: ${missing.slice(0, 10).join(", ")}${missing.length > 10 ? "…" : ""}`,
    );
  }
  return {
    text: JSON.stringify(catalog, null, 2) + "\n",
    stats: { updated, unchanged },
  };
}

function main() {
  const arg = process.argv[2];
  const payloadPath = arg
    ? path.resolve(process.cwd(), arg)
    : DEFAULT_PAYLOAD;
  const payload = JSON.parse(readFileSync(payloadPath, "utf8"));
  if (!Array.isArray(payload)) {
    throw new Error(`payload at ${payloadPath} must be a JSON array`);
  }
  const byId = new Map();
  for (const row of payload) {
    if (!row || typeof row !== "object") {
      throw new Error("payload rows must be objects");
    }
    const { id, en, sv } = row;
    if (typeof id !== "string" || !id) {
      throw new Error(`payload row missing id: ${JSON.stringify(row).slice(0, 200)}`);
    }
    if (typeof en !== "string" || !en.trim()) {
      throw new Error(`row ${id} missing 'en' translation`);
    }
    if (typeof sv !== "string" || !sv.trim()) {
      throw new Error(`row ${id} missing 'sv' translation`);
    }
    if (byId.has(id)) {
      throw new Error(`duplicate id in payload: ${id}`);
    }
    byId.set(id, { en, sv });
  }
  console.log(`payload: ${byId.size} translations from ${payloadPath}`);

  const seed = readFileSync(SEED_PATH, "utf8");
  const { text: newSeed, stats: ss } = rewriteSeed(seed, byId);
  if (newSeed !== seed) writeFileSync(SEED_PATH, newSeed);
  console.log(
    `seed.sql: ${ss.rowCount} exhibitor rows | ${ss.updated} updated | ${ss.unchanged} already-current`,
  );

  const catalogText = readFileSync(CATALOG_PATH, "utf8");
  const { text: newCatalog, stats: cs } = rewriteCatalog(catalogText, byId);
  if (newCatalog !== catalogText) writeFileSync(CATALOG_PATH, newCatalog);
  console.log(
    `catalog.json: ${cs.updated} updated | ${cs.unchanged} already-current`,
  );
}

main();
