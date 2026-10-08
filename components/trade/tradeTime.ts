/**
 * Formatowanie czasu dla listy ofert.
 *
 * Daty przychodzą z API jako stringi. Nie mogę sprawdzić, w jakim formacie
 * (ISO czy coś innego), więc każda funkcja sprawdza `Date.parse` i przy
 * niepoprawnym wejściu zwraca placeholder zamiast `Invalid Date`.
 */

const PLACEHOLDER = "—"

function toMs(value: string): number | null {
  const ms = Date.parse(value)
  return Number.isFinite(ms) ? ms : null
}

/** "just now" / "12m ago" / "5h ago" / "3d ago" */
export function formatRelativeAge(value: string, nowMs: number): string {
  const ms = toMs(value)
  if (ms === null) return PLACEHOLDER

  const seconds = Math.round((nowMs - ms) / 1000)

  // Przyszłość — daty z serwera bywają lekko w przyszłości przez zegar.
  if (seconds < 45) return "just now"
  if (seconds < 3600) return `${Math.round(seconds / 60)}m ago`
  if (seconds < 86400) return `${Math.round(seconds / 3600)}h ago`
  return `${Math.round(seconds / 86400)}d ago`
}

/** "45s" / "4m 12s" / "2h 05m" / "3d 4h" */
export function formatCountdown(value: string, nowMs: number): string {
  const ms = toMs(value)
  if (ms === null) return PLACEHOLDER

  const seconds = Math.floor((ms - nowMs) / 1000)

  if (seconds <= 0) return "expired"

  const days = Math.floor(seconds / 86400)
  const hours = Math.floor((seconds % 86400) / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  const rest = seconds % 60

  if (days > 0) return `${days}d ${hours}h`
  if (hours > 0) return `${hours}h ${String(minutes).padStart(2, "0")}m`
  if (minutes > 0) return `${minutes}m ${String(rest).padStart(2, "0")}s`
  return `${rest}s`
}

export function isExpired(value: string, nowMs: number): boolean {
  const ms = toMs(value)
  if (ms === null) return false
  return ms <= nowMs
}