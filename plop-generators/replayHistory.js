import fs from "fs"
import path from "path"
import { fileURLToPath } from "url"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const HISTORY_ROOT = path.resolve(__dirname, "answerHistory")

export default function replayHistory(plop) {
  plop.setGenerator("Replay Answer History", {
    description: "Masowe odtworzenie wszystkich zapisanych generatorów",

    prompts: async (inquirer) => {
      const generators = fs
        .readdirSync(HISTORY_ROOT)
        .filter((dir) => fs.statSync(path.join(HISTORY_ROOT, dir)).isDirectory())

      if (!generators.length) {
        throw new Error("Brak zapisanej historii")
      }

      const { selectedGenerators } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "selectedGenerators",
          message: "Które generatory odtworzyć?",
          choices: generators,
          validate: (v) => v.length > 0 || "Wybierz przynajmniej jeden generator",
        },
      ])

      return { selectedGenerators }
    },

    actions: function (answers) {
      const actions = []

      for (const generatorName of answers.selectedGenerators) {
        const dir = path.join(HISTORY_ROOT, generatorName)

        const files = fs.readdirSync(dir).filter((f) => f.endsWith(".json"))

        for (const file of files) {
          const fullPath = path.join(dir, file)
          const historyAnswers = JSON.parse(fs.readFileSync(fullPath, "utf-8"))

          actions.push({
            type: "replayGenerator",
            generatorName,
            historyAnswers,
          })
        }
      }

      return actions
    },
  })

  /**
   * Custom action: replay generator
   */
  plop.setActionType("replayGenerator", async (answers, config, plopApi) => {
    const generator = plopApi.getGenerator(config.generatorName)

    if (!generator) {
      throw new Error(`Generator "${config.generatorName}" nie istnieje`)
    }

    console.log(
      `\n▶ Replay: ${config.generatorName} (${config.historyAnswers.schema ?? ""} ${
        config.historyAnswers.table ?? config.historyAnswers.method ?? ""
      })`,
    )

    const actions =
      typeof generator.actions === "function" ? generator.actions(config.historyAnswers) : generator.actions

    for (const action of actions) {
      await plopApi.executeAction(action, config.historyAnswers)
    }

    return `✔ ${config.generatorName} OK`
  })
}
