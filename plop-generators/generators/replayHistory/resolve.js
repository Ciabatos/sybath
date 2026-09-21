import fs from "fs"
import path from "path"
import { GENERATORS } from "./registry.js"

export const HISTORY_ROOT = path.resolve("plop-generators/answerHistory")

/**
 * Nazwy folderów (generatorów) w answerHistory, które mają zarejestrowany generator.
 */
export function listGeneratorFolders() {
  if (!fs.existsSync(HISTORY_ROOT)) return []

  return fs.readdirSync(HISTORY_ROOT).filter((name) => {
    try {
      const abs = path.join(HISTORY_ROOT, name)
      return fs.statSync(abs).isDirectory() && !!GENERATORS[name]
    } catch {
      return false
    }
  })
}

/**
 * Pliki .json w wybranym folderze generatora.
 * Zwraca [{ name, value }] gdzie value = "getTable/public_users_answers.json"
 * (ten sam format co wcześniej — actions.js nie wymaga zmian).
 */
export function listHistoryFilesFor(generatorName) {
  const genDir = path.join(HISTORY_ROOT, generatorName)
  if (!fs.existsSync(genDir)) return []

  return fs
    .readdirSync(genDir)
    .filter((f) => f.endsWith(".json"))
    .map((file) => {
      const key = `${generatorName}/${file}`
      return { name: file, value: key }
    })
}

/**
 * Zostawiam dla kompatybilności — zwraca wszystkie pliki ze wszystkich
 * zarejestrowanych generatorów (płaska lista).
 */
export function listHistoryFiles() {
  return listGeneratorFolders().flatMap((gen) => listHistoryFilesFor(gen))
}

export function readHistoryFile(fullPath) {
  return JSON.parse(fs.readFileSync(fullPath, "utf-8"))
}

export async function resolveReplay(historyAnswers, targetGenerator) {
  const entry = GENERATORS[targetGenerator]
  if (!entry) throw new Error(`No generator registered as "${targetGenerator}"`)

  // Generatory z resolve-through-DB (getTable / getMethodFetcher / getMethodAction)
  // zapisują promptAnswers. Generatory czysto-plikowe (create*) nie mają
  // promptAnswers — wtedy przekazujemy cały obiekt.
  const input = historyAnswers?.promptAnswers ?? historyAnswers
  return entry.resolve(input)
}
