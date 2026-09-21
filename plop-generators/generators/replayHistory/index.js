import { executeAddActions, getReplayHistoryActions } from "./actions.js"
import { getReplayHistoryPrompts } from "./prompts.js"
import { HISTORY_ROOT, listHistoryFiles, readHistoryFile, resolveReplay } from "./resolve.js"

export {
  executeAddActions,
  getReplayHistoryActions,
  getReplayHistoryPrompts,
  HISTORY_ROOT,
  listHistoryFiles,
  readHistoryFile,
  resolveReplay,
}

export default function replayHistory(plop) {
  plop.setActionType("replayGenerator", async (_outerAnswers, config, plopApi) => {
    const { targetGenerator, historyAnswers, sourceFile } = config

    console.log(`▶ Replaying ${targetGenerator} <- ${sourceFile}`)

    const freshAnswers = await resolveReplay(historyAnswers, targetGenerator)
    const { changes, failures } = await executeAddActions(plopApi, targetGenerator, freshAnswers)

    if (failures.length) {
      for (const f of failures) console.error(`  ✖ ${f.error}  (${f.path})`)
      throw new Error(`Replay failed for ${sourceFile}`)
    }

    console.log(`✔ ${targetGenerator} <- ${sourceFile}: ${changes.length} change(s)`)
    return `Replayed ${targetGenerator} <- ${sourceFile}`
  })

  plop.setGenerator("replayHistory", {
    description: "Replay saved generator answers (fresh from DB via resolve.js)",
    prompts: getReplayHistoryPrompts,
    actions: getReplayHistoryActions(),
  })
}
