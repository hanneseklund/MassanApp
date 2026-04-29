#!/usr/bin/env node
// One-off wrapper for agent task -01c3-exhibitors.
//
// Rewrites the `public.exhibitors.description` field in
// `supabase/seed/seed.sql` and the matching `description` in
// `web/data/catalog.json` from a plain string literal into the
// dual-language `{ en, sv }` shape introduced by sub-task 01a.
// Both slots carry the existing seeded copy (duplicate-fill); real
// Swedish translations land in sub-task 04.
//
// Idempotent: rows whose description is already wrapped are left
// alone. Null descriptions stay null.
//
// Usage:
//   node scripts/wrap_exhibitor_descriptions.mjs
//
// The script edits files in place. Re-run after every exhibitor
// rescrape (the scrape produces plain-text descriptions) to keep the
// seed in the dual-language shape until rescrape tooling itself
// emits `{ en, sv }`.

import { readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const REPO = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
);
const SEED_PATH = path.join(REPO, "supabase/seed/seed.sql");
const CATALOG_PATH = path.join(REPO, "web/data/catalog.json");

const INSERT_HEADER =
  "insert into public.exhibitors (id, event_id, name, booth, description, website, logo) values\n";
const ON_CONFLICT_LINE = "on conflict (id) do update set";

function rewriteSeed(seed) {
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
  const { newBody, stats } = rewriteValuesBody(body);
  return { text: before + newBody + after, stats };
}

function rewriteValuesBody(body) {
  let out = "";
  let i = 0;
  let rowCount = 0;
  let rewrittenCount = 0;
  let nullCount = 0;
  let alreadyWrappedCount = 0;
  while (i < body.length) {
    const c = body[i];
    if (c === "(") {
      const closeIdx = findMatchingClose(body, i);
      const inner = body.slice(i + 1, closeIdx);
      const { newInner, status } = rewriteRow(inner);
      out += "(" + newInner + ")";
      i = closeIdx + 1;
      rowCount++;
      if (status === "rewritten") rewrittenCount++;
      else if (status === "null") nullCount++;
      else if (status === "already-wrapped") alreadyWrappedCount++;
    } else {
      out += c;
      i++;
    }
  }
  return {
    newBody: out,
    stats: { rowCount, rewrittenCount, nullCount, alreadyWrappedCount },
  };
}

// Find the index of `)` that closes the `(` at `openIdx`, treating
// single-quoted strings (with `''` escapes) as opaque and tracking
// paren depth so nested calls (e.g. `jsonb_build_object(...)` inside
// an already-wrapped row) are skipped.
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
    `unterminated paren starting at offset ${openIdx}: ${text.slice(openIdx, openIdx + 80)}`,
  );
}

// Advance past a single-quoted SQL string literal starting at the
// opening quote at index `i`. Handles `''` doubled-quote escapes.
// Returns the index just past the closing quote.
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

function rewriteRow(inner) {
  const fields = splitTopLevelByComma(inner);
  if (fields.length !== 7) {
    throw new Error(
      `expected 7 fields per exhibitor row, got ${fields.length}: ${inner.slice(0, 200)}`,
    );
  }
  const desc = fields[4];
  const trimmed = desc.trim();
  if (trimmed === "null") {
    return { newInner: fields.join(","), status: "null" };
  }
  if (trimmed.startsWith("jsonb_build_object")) {
    return { newInner: fields.join(","), status: "already-wrapped" };
  }
  if (!trimmed.startsWith("'")) {
    throw new Error(
      `unexpected description token: ${trimmed.slice(0, 80)} (in row ${inner.slice(0, 100)})`,
    );
  }
  const leading = desc.match(/^\s*/)[0];
  const trailing = desc.match(/\s*$/)[0];
  const literal = desc.slice(leading.length, desc.length - trailing.length);
  const wrapped = `jsonb_build_object('en', ${literal}, 'sv', ${literal})`;
  fields[4] = leading + wrapped + trailing;
  return { newInner: fields.join(","), status: "rewritten" };
}

// Split on commas at the top level: not inside a SQL string literal
// and not inside a nested paren group (so commas inside an already-
// wrapped `jsonb_build_object('en', ..., 'sv', ...)` don't split the
// row). Preserves surrounding whitespace exactly.
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

function rewriteCatalog(catalogText) {
  const catalog = JSON.parse(catalogText);
  if (!Array.isArray(catalog.exhibitors)) {
    throw new Error("catalog.json has no exhibitors array");
  }
  let rewritten = 0;
  let alreadyWrapped = 0;
  let nullCount = 0;
  for (const ex of catalog.exhibitors) {
    const d = ex.description;
    if (d == null) {
      nullCount++;
      continue;
    }
    if (typeof d === "string") {
      ex.description = { en: d, sv: d };
      rewritten++;
      continue;
    }
    if (typeof d === "object" && !Array.isArray(d) && "en" in d) {
      alreadyWrapped++;
      continue;
    }
    throw new Error(
      `unexpected catalog exhibitor description shape for ${ex.id}: ${JSON.stringify(d)}`,
    );
  }
  // catalog.json is committed with 2-space indentation and a trailing
  // newline; preserve that.
  return {
    text: JSON.stringify(catalog, null, 2) + "\n",
    stats: {
      rowCount: catalog.exhibitors.length,
      rewrittenCount: rewritten,
      alreadyWrappedCount: alreadyWrapped,
      nullCount,
    },
  };
}

function main() {
  const seed = readFileSync(SEED_PATH, "utf8");
  const { text: newSeed, stats: seedStats } = rewriteSeed(seed);
  if (newSeed !== seed) {
    writeFileSync(SEED_PATH, newSeed);
  }
  console.log(
    `seed.sql: ${seedStats.rowCount} exhibitor rows | ${seedStats.rewrittenCount} wrapped | ${seedStats.alreadyWrappedCount} already wrapped | ${seedStats.nullCount} null`,
  );

  const catalogText = readFileSync(CATALOG_PATH, "utf8");
  const { text: newCatalog, stats: catalogStats } =
    rewriteCatalog(catalogText);
  if (newCatalog !== catalogText) {
    writeFileSync(CATALOG_PATH, newCatalog);
  }
  console.log(
    `catalog.json: ${catalogStats.rowCount} exhibitor rows | ${catalogStats.rewrittenCount} wrapped | ${catalogStats.alreadyWrappedCount} already wrapped | ${catalogStats.nullCount} null`,
  );

  if (seedStats.rowCount !== catalogStats.rowCount) {
    throw new Error(
      `row-count mismatch between seed.sql (${seedStats.rowCount}) and catalog.json (${catalogStats.rowCount})`,
    );
  }
}

main();
