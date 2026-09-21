import { listHookFolders } from "../../helpers/targets.js"
import { resolveCreateAtomClientSingleton } from "./resolve.js"

export async function getCreateAtomClientSingletonPrompts(inquirer) {
  const { choosenPath } = await inquirer.prompt([
    {
      type: "list",
      name: "choosenPath",
      message: "Wybierz folder w hooks",
      choices: listHookFolders(),
    },
  ])

  const { inputName } = await inquirer.prompt([
    {
      type: "input",
      name: "inputName",
      message: "Atom name without extension Atom",
    },
  ])

  return resolveCreateAtomClientSingleton({ choosenPath, inputName })
}
