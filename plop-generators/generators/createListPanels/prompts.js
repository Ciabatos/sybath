import { listComponentsFolders } from "../../helpers/targets.js"
import { resolveCreateListPanels } from "./resolve.js"

export async function getCreateListPanelsPrompts(inquirer) {
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
      message: "Panel name without .tsx extension :",
    },
  ])

  return resolveCreateListPanels({ choosenPath, newPanelName })
}
