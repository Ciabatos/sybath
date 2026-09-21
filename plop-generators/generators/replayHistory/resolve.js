import fs from "fs"
import path from "path"
import { GENERATORS } from "./registry.js"

export const HISTORY_ROOT = path.resolve("plop-generators/answerHistory")

export function listHistoryFiles() {
  if (!fs.existsSync(HISTORY_ROOT)) return []

  const out = []
  for (const gen of fs.readdirSync(HISTORY_ROOT)) {
    const genDir = path.join(HISTORY_ROOT, gen)
    if (!fs.statSync(genDir).isDirectory()) continue
    if (!GENERATORS[gen]) continue // pomija foldery bez zarejestrowanego generatora

    for (const file of fs.readdirSync(genDir).filter((f) => f.endsWith(".json"))) {
      const key = `${gen}/${file}`
      out.push({ name: key, value: key })
    }
  }
  return out
}

export function readHistoryFile(fullPath) {
  return JSON.parse(fs.readFileSync(fullPath, "utf-8"))
}

export async function resolveReplay(historyAnswers, targetGenerator) {
  const entry = GENERATORS[targetGenerator]
  if (!entry) throw new Error(`No generator registered as "${targetGenerator}"`)
  if (!historyAnswers?.promptAnswers) {
    throw new Error(`Missing promptAnswers — cannot resolve for "${targetGenerator}"`)
  }
  return entry.resolve(historyAnswers.promptAnswers)
}
