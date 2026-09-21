import fs from "fs"
import path from "path"

/**
 * Katalogi, które zawsze formatujemy.
 * Kolejność nie ma znaczenia — Prettier sam przejdzie rekurencyjnie.
 */
export const DEFAULT_TARGET_DIRS = ["db/postgresMainDatabase", "methods", "store/atoms", "app/api"]

const EXCLUDED = new Set(["node_modules", ".next", "dist", "build", ".git", ".turbo"])

/**
 * Zwraca absolutne ścieżki do katalogów, które istnieją i nie są wykluczone.
 * Bez promptów, bez opcji — zawsze cały DEFAULT_TARGET_DIRS.
 */
export function resolvePathsToFormat({ cwd = process.cwd() } = {}) {
  return DEFAULT_TARGET_DIRS.map((d) => path.resolve(cwd, d)).filter((abs) => {
    if (!fs.existsSync(abs)) return false
    const first = path.relative(cwd, abs).split(path.sep)[0]
    return !EXCLUDED.has(first)
  })
}
