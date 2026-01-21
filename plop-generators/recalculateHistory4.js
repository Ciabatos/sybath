import fs from "fs"
import { default as nodePlop } from "node-plop"
import path from "path"

const HISTORY_ROOT = path.resolve("plop-generators/answerHistory")

export default function recalculateHistory(plop) {
  plop.setGenerator("recalculateHistory", {
    description: "Replay saved generator answers",
    prompts: [
      {
        type: "checkbox",
        name: "selectedGenerators",
        message: "Select generators to replay",
        choices: fs.readdirSync(HISTORY_ROOT).filter((f) => fs.statSync(path.join(HISTORY_ROOT, f)).isDirectory()),
      },
    ],
    actions: (answers) => {
      return answers.selectedGenerators.map((generatorName) => {
        return {
          type: "replayGenerator",
          generatorName,
        }
      })
    },
  })

  plop.setActionType("replayGenerator", async (answers, config) => {
    const plop = await nodePlop(path.resolve("./plop-generators/plopfile.js"))

    const generator = plop.getGenerator(config.generatorName)

    const dir = path.join(HISTORY_ROOT, config.generatorName)
    const files = fs.readdirSync(dir).filter((f) => f.endsWith(".json"))

    for (const file of files) {
      const historyAnswers = JSON.parse(fs.readFileSync(path.join(dir, file), "utf-8"))
      const bypassArr = Object.values(historyAnswers.promptAnswers)

      const newAnswers = await generator.runPrompts(bypassArr)
      console.log("Answers after runPrompts:", newAnswers)
    }
  })
}
