import path from "path"

import { collectFilesToRemove, HISTORY_ROOT, readHistoryFile } from "./resolve.js"

/**
 * Buduje akcje dla rollbacku.
 * Wynik: jedna akcja "removeFiles" z kompletną listą plików do usunięcia.
 */
export function getRollbackActions() {
  return (answers) => {
    const actions = []
    const entries = []

    for (const fileName of answers.selectedFiles) {
      const fullPath = path.join(HISTORY_ROOT, answers.selectedGenerator, fileName)

      try {
        const json = readHistoryFile(fullPath)
        if (!Array.isArray(json.filesCreated)) {
          actions.push(() => `⚠ ${fileName}: brak filesCreated w JSON — pomijam.`)
          continue
        }
        entries.push({ filesCreated: json.filesCreated })
      } catch (err) {
        actions.push(() => `⚠ Cannot read ${fullPath}: ${err.message}`)
      }
    }

    const files = collectFilesToRemove(entries)

    if (files.length === 0) {
      actions.push(() => "⚠ Brak plików do usunięcia.")
      return actions
    }

    actions.push({
      type: "removeFiles",
      files,
    })

    return actions
  }
}
