import fs from "fs"
import path from "path"
import { GENERATORS } from "./registry.js"
import { HISTORY_ROOT, readHistoryFile } from "./resolve.js"

export function getReplayHistoryActions() {
  return (answers) => {
    const actions = []

    for (const fileKey of answers.selectedFiles) {
      const [gen, fileName] = fileKey.split("/")
      const fullPath = path.join(HISTORY_ROOT, gen, fileName)

      let historyAnswers
      try {
        historyAnswers = readHistoryFile(fullPath)
      } catch (err) {
        actions.push(() => `⚠ Cannot read ${fullPath}: ${err.message}`)
        continue
      }

      if (!historyAnswers?.promptAnswers) {
        actions.push(() => `⚠ ${fileKey}: brak promptAnswers — nie można odpalić resolve.`)
        continue
      }

      actions.push({
        type: "replayGenerator",
        targetGenerator: gen,
        historyAnswers,
        sourceFile: `${gen}/${fileName}`,
      })
    }

    return [...actions, { type: "PrettierFormat" }]
  }
}

export async function executeAddActions(plop, targetGenerator, answers) {
  const entry = GENERATORS[targetGenerator]
  if (!entry) throw new Error(`No generator registered as "${targetGenerator}"`)

  let actions = entry.actions()
  if (typeof actions === "function") actions = actions(answers)

  const plopfilePath = typeof plop.getPlopfilePath === "function" ? plop.getPlopfilePath() : process.cwd()

  const changes = []
  const failures = []

  for (const action of actions) {
    if (!action || typeof action === "string") continue
    if (action.type !== "add") continue

    if (typeof action.skip === "function") {
      if (action.skip(answers)) continue
    } else if (action.skip === true) {
      continue
    }

    try {
      const renderedPath = plop.renderString(action.path, answers)
      const fullPath = path.resolve(plopfilePath, renderedPath)

      const templatePath = path.resolve(plopfilePath, action.templateFile)
      const templateContent = fs.readFileSync(templatePath, "utf-8")
      const rendered = plop.renderString(templateContent, answers)

      fs.mkdirSync(path.dirname(fullPath), { recursive: true })
      fs.writeFileSync(fullPath, rendered)

      changes.push({ path: fullPath, type: "add" })
    } catch (err) {
      failures.push({ error: err.message, path: action.path })
    }
  }

  return { changes, failures }
}
