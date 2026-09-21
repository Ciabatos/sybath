import { listGeneratorFolders, listHistoryFilesFor } from "./resolve.js"

export async function getReplayHistoryPrompts(inquirer) {
  const folders = listGeneratorFolders()
  if (folders.length === 0) {
    throw new Error("Brak folderów z historią w plop-generators/answerHistory")
  }

  const { selectedGenerator } = await inquirer.prompt([
    {
      type: "list",
      name: "selectedGenerator",
      message: "Wybierz generator (folder w answerHistory)",
      choices: folders,
    },
  ])

  const fileChoices = listHistoryFilesFor(selectedGenerator)
  if (fileChoices.length === 0) {
    throw new Error(`Brak plików .json w plop-generators/answerHistory/${selectedGenerator}`)
  }

  const { selectedFiles } = await inquirer.prompt([
    {
      type: "checkbox",
      name: "selectedFiles",
      message: `Wybierz pliki z ${selectedGenerator} do replay`,
      choices: fileChoices,
      validate: (answer) => (answer.length < 1 ? "Musisz wybrać przynajmniej jeden plik." : true),
    },
  ])

  return { selectedGenerator, selectedFiles }
}
