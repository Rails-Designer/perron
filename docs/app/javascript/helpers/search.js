export function excerpt(text, query, maxLength = 150) {
  const terms = query.trim().split(/\s+/).filter(Boolean)
  if (!terms.length) return truncate(text, maxLength)

  const pattern = terms.map(escapeRegex).join("|")
  const match = text.match(new RegExp(pattern, "i"))
  if (!match) return truncate(text, maxLength)

  const halfWindow = maxLength / 2
  const start = Math.max(0, match.index - halfWindow)
  const end = Math.min(text.length, start + maxLength)
  const snippet = text.slice(start, end)

  return `${start > 0 ? "…" : ""}${snippet}${end < text.length ? "…" : ""}`
}

export function highlight(text, query) {
  const terms = query.trim().split(/\s+/).filter(Boolean)
  if (!terms.length) return text

  const pattern = terms.map(escapeRegex).join("|")

  return text.replace(new RegExp(`(${pattern})`, "gi"), "<mark>$1</mark>")
}

function truncate(text, length) {
  return text.length > length ? `${text.slice(0, length)}…` : text
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
}
