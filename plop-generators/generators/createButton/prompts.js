import { listComponentsFolders } from "../../helpers/targets.js"
import { resolveCreateButton } from "./resolve.js"

export async function getCreateButtonPrompts(inquirer) {
  const { choosenPath } = await inquirer.prompt([
    {
      type: "list",
      name: "choosenPath",
      message: "Wybierz folder w components",
      choices: listComponentsFolders(),
    },
  ])

  const { newPanelName } = await inquirer.prompt([
    {
      type: "input",
      name: "newPanelName",
      message: "Button name without .tsx extension :",
    },
  ])

  return resolveCreateButton({ choosenPath, newPanelName })
}
