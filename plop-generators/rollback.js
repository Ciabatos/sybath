import fs from "fs"
import path from "path"

const HISTORY_ROOT = path.resolve("plop-generators/answerHistory")

export default function rollback(plop) {
  const generatorName = "rollback"

  plop.setGenerator(generatorName, {
    description: "Usuwa wcześniej wygenerowane pliki",
    prompts: [
      {
        type: "list",
        name: "selectedGenerator",
        message: "Wybierz generator",
        choices: () =>
          fs.readdirSync(HISTORY_ROOT).filter((f) => fs.statSync(path.join(HISTORY_ROOT, f)).isDirectory()),
      },
      {
        type: "checkbox",
        name: "selectedFiles",
        message: "Wybierz pliki do usunięcia",
        choices: (answers) => {
          const generatorPath = path.join(HISTORY_ROOT, answers.selectedGenerator)

          return fs.readdirSync(generatorPath).filter((f) => fs.statSync(path.join(generatorPath, f)).isFile())
        },
        validate: (answer) => {
          if (answer.length < 1) {
            return "Musisz wybrać przynajmniej jeden plik."
          }

          return true
        },
      },
    ],
    actions: [
      {
        type: "removeFiles",
      },
    ],
  })
}
