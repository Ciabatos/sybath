import fs from "fs"
import path from "path"

export const HISTORY_ROOT = path.resolve("plop-generators/answerHistory")

/**
 * Nazwy folderów w answerHistory (np. "getTable", "getMethodFetcher", ...).
 * Pomija pliki i foldery nie-czytelne.
 */
export function listGeneratorFolders() {
  if (!fs.existsSync(HISTORY_ROOT)) return []

  return fs.readdirSync(HISTORY_ROOT).filter((name) => {
    try {
      return fs.statSync(path.join(HISTORY_ROOT, name)).isDirectory()
    } catch {
      return false
    }
  })
}

/**
 * Zwraca [{ file, filesCreated, parseError? }, ...] dla danego generatora.
 * - filtruje tylko .json
 * - bezpiecznie parsuje (parseError zamiast wywalenia)
 * - normalizuje filesCreated do tablicy stringów
 */
export function listHistoryFiles(generatorName) {
  const genDir = path.join(HISTORY_ROOT, generatorName)
  if (!fs.existsSync(genDir)) return []

  return fs
    .readdirSync(genDir)
    .filter((f) => f.endsWith(".json") && fs.statSync(path.join(genDir, f)).isFile())
    .map((file) => {
      const fullPath = path.join(genDir, file)
      try {
        const json = JSON.parse(fs.readFileSync(fullPath, "utf8"))
        const filesCreated = Array.isArray(json.filesCreated) ? json.filesCreated : []
        return { file, filesCreated }
      } catch {
        return { file, filesCreated: [], parseError: true }
      }
    })
}

export function readHistoryFile(fullPath) {
  return JSON.parse(fs.readFileSync(fullPath, "utf-8"))
}

/**
 * Scala filesCreated z wybranych plików historii w jedną, odfiltrowaną listę.
 * Deduplikuje (jak dwa pliki historii nakładają się na ten sam plik).
 */
export function collectFilesToRemove(entries) {
  const set = new Set()
  for (const entry of entries) {
    for (const f of entry.filesCreated ?? []) set.add(f)
  }
  return [...set]
}
