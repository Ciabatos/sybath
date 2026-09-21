import { resolvePathsToFormat } from "./resolve.js"

/**
 * Zawsze jedna akcja: PrettierFormat z pełną listą DEFAULT_TARGET_DIRS.
 */
export function getFormatPrettierActions() {
  return () => {
    const paths = resolvePathsToFormat()

    if (paths.length === 0) {
      return [() => "⚠ Brak katalogów do sformatowania."]
    }

    return [
      {
        type: "PrettierFormat",
        paths,
      },
    ]
  }
}
