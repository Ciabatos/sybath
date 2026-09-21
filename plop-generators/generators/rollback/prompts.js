import { listGeneratorFolders, listHistoryFiles } from "./resolve.js"

export async function getRollbackPrompts(inquirer) {
  const folders = listGeneratorFolders()
  if (folders.length === 0) {
    throw new Error("Brak katalogów z historią w plop-generators/answerHistory")
  }

  const { selectedGenerator } = await inquirer.prompt([
    {
      type: "list",
      name: "selectedGenerator",
      message: "Wybierz generator",
      choices: folders,
    },
  ])

  const fileEntries = listHistoryFiles(selectedGenerator)
  if (fileEntries.length === 0) {
    throw new Error(`Brak plików historii w plop-generators/answerHistory/${selectedGenerator}`)
  }

  const { selectedFiles } = await inquirer.prompt([
    {
      type: "checkbox",
      name: "selectedFiles",
      message: "Wybierz pliki do usunięcia",
      choices: fileEntries.map((f) => ({
        name: f.parseError ? `${f.file}  ⚠ (parse error)` : `${f.file}  (${f.filesCreated.length} plików)`,
        value: f.file,
      })),
      validate: (answer) => (answer.length < 1 ? "Musisz wybrać przynajmniej jeden plik." : true),
    },
  ])

  return { selectedGenerator, selectedFiles }
}
