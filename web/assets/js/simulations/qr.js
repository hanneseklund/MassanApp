// QR code for a ticket. The payload binds the ticket id to its event
// id with a salt so two tickets with the same id across events would
// still produce distinct payloads. The SVG renderer draws a visually
// QR-like matrix: three finder patterns in the corners and a
// hash-driven body fill. It is not a valid venue-access credential.

const QR_SALT = "stockholmsmassan-prototype";
const QR_SIZE = 25;

export function ticketQrPayload(ticket) {
  return `massan:${ticket.id || "new"}:${ticket.event_id}:${QR_SALT}`;
}

function qrHashBytes(str, length) {
  const out = new Uint8Array(length);
  let h = 0x811c9dc5;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 0x01000193);
  }
  for (let i = 0; i < length; i++) {
    h ^= (i + 1) * 0x9e3779b1;
    h = Math.imul(h, 0x01000193);
    out[i] = (h >>> (i % 24)) & 0xff;
  }
  return out;
}

function ticketQrMatrix(payload) {
  const size = QR_SIZE;
  const m = Array.from({ length: size }, () => new Array(size).fill(0));
  const finders = [
    [0, 0],
    [0, size - 7],
    [size - 7, 0],
  ];
  for (const [fr, fc] of finders) {
    for (let r = 0; r < 7; r++) {
      for (let c = 0; c < 7; c++) {
        const on =
          r === 0 ||
          r === 6 ||
          c === 0 ||
          c === 6 ||
          (r >= 2 && r <= 4 && c >= 2 && c <= 4);
        m[fr + r][fc + c] = on ? 1 : 0;
      }
    }
  }
  const inFinderZone = (r, c) => {
    const tl = r < 8 && c < 8;
    const tr = r < 8 && c >= size - 8;
    const bl = r >= size - 8 && c < 8;
    return tl || tr || bl;
  };
  const bytes = qrHashBytes(payload, size * size);
  for (let r = 0; r < size; r++) {
    for (let c = 0; c < size; c++) {
      if (inFinderZone(r, c)) continue;
      m[r][c] = bytes[r * size + c] & 1;
    }
  }
  return m;
}

function ticketQrSvg(payload) {
  const matrix = ticketQrMatrix(payload);
  const size = matrix.length;
  const cell = 8;
  const quiet = 2;
  const total = (size + quiet * 2) * cell;
  let cells = "";
  for (let r = 0; r < size; r++) {
    for (let c = 0; c < size; c++) {
      if (!matrix[r][c]) continue;
      const x = (c + quiet) * cell;
      const y = (r + quiet) * cell;
      cells += `<rect x="${x}" y="${y}" width="${cell}" height="${cell}"/>`;
    }
  }
  return (
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${total} ${total}" ` +
    `width="100%" height="100%" role="img" aria-label="Ticket QR code">` +
    `<rect width="100%" height="100%" fill="#ffffff"/>` +
    `<g fill="#0f172a">${cells}</g></svg>`
  );
}

export function ticketQrSvgFor(ticket) {
  const payload = ticket.qr_payload || ticketQrPayload(ticket);
  return ticketQrSvg(payload);
}
