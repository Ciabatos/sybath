import fs from "fs"
import path from "path"

const HISTORY_ROOT = path.resolve("plop-generators/answerHistory")
const actionPrettier = [
  {
    type: "PrettierFormat",
  },
]

export default function replayHistory(plop) {
  plop.setGenerator("replayHistory", {
    description: "Replay saved generator answers",

    prompts: [
      {
        type: "checkbox",
        name: "selectedGenerators",
        message: "Select generators to replay",
        choices: fs.readdirSync(HISTORY_ROOT).filter((f) => fs.statSync(path.join(HISTORY_ROOT, f)).isDirectory()),
        validate: (answer) => {
          if (answer.length < 1) {
            return "Musisz wybrać przynajmniej jeden generator."
          }
          return true
        },
      },
    ],

    actions: (answers) => {
      const actions = []

      for (const generatorName of answers.selectedGenerators) {
        const dir = path.join(HISTORY_ROOT, generatorName)
        const files = fs.readdirSync(dir).filter((f) => f.endsWith(".json"))

        for (const file of files) {
          const historyAnswers = JSON.parse(fs.readFileSync(path.join(dir, file), "utf-8"))

          // Pobierz generator
          const generator = plop.getGenerator(generatorName)

          if (!generator) {
            console.warn(`⚠ Generator "${generatorName}" not found, skipping...`)
            continue
          }

          // Pobierz akcje z generatora
          const generatorActions =
            typeof generator.actions === "function" ? generator.actions(historyAnswers) : generator.actions

          // Dodaj log przed akcjami
          actions.push(() => {
            console.log(`▶ Replaying ${generatorName} - ${file}`)
            return `Starting replay of ${generatorName} - ${file}`
          })

          // Dodaj każdą akcję z historii do listy akcji
          for (const action of generatorActions) {
            // Jeśli akcja ma skip, sprawdź czy należy ją pominąć
            if (typeof action.skip === "function") {
              const skipReason = action.skip(historyAnswers)
              if (skipReason) {
                actions.push(() => `⊘ Skipped: ${skipReason}`)
                continue
              }
            } else if (action.skip === true) {
              actions.push(() => `⊘ Skipped`)
              continue
            }

            // Jeśli to string (komentarz), dodaj go
            if (typeof action === "string") {
              actions.push(() => action)
              continue
            }

            // Dodaj akcję z nadpisanymi danymi z historii
            actions.push({
              ...action,
              // Nadpisz lub dodaj data z historyAnswers
              data: typeof action.data === "function" ? action.data : { ...historyAnswers, ...action.data },
            })
          }

          // Dodaj log po akcjach
          actions.push(() => `✔ ${generatorName} - ${file} completed successfully`)
        }
      }
      console.dir(actions, { depth: null, maxArrayLength: null })

      return [...actions, ...actionPrettier]
    },
  })
}
