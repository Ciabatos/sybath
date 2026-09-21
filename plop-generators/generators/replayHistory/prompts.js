import { listHistoryFiles } from "./resolve.js"

export async function getReplayHistoryPrompts(inquirer) {
  const choices = listHistoryFiles()
  if (choices.length === 0) {
    throw new Error("Brak plików historii w plop-generators/answerHistory")
  }

  const { selectedFiles } = await inquirer.prompt([
    {
      type: "checkbox",
      name: "selectedFiles",
      message: "Select history files to replay",
      choices,
      validate: (answer) => (answer.length < 1 ? "Musisz wybrać przynajmniej jeden plik." : true),
    },
  ])

  return { selectedFiles }
}
