import { removeFiles } from "../../helpers/removeFiles.js"
import { getRollbackActions } from "./actions.js"
import { getRollbackPrompts } from "./prompts.js"
import {
  collectFilesToRemove,
  HISTORY_ROOT,
  listGeneratorFolders,
  listHistoryFiles,
  readHistoryFile,
} from "./resolve.js"

export {
  collectFilesToRemove,
  getRollbackActions,
  getRollbackPrompts,
  HISTORY_ROOT,
  listGeneratorFolders,
  listHistoryFiles,
  readHistoryFile,
}

export default function rollback(plop) {
  // Rejestracja action type — wcześniej musiała być gdzieś indziej.
  plop.setActionType("removeFiles", async (_answers, config) => {
    const files = config?.files ?? []
    if (files.length === 0) return "No files to remove"

    const result = await removeFiles(files)
    return result
  })

  plop.setGenerator("rollback", {
    description: "Usuwa wcześniej wygenerowane pliki",
    prompts: getRollbackPrompts,
    actions: getRollbackActions(),
  })
}
