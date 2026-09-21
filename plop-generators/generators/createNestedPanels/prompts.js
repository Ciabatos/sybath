import { listComponentsFolders } from "../../helpers/targets.js"
import { resolveCreateNestedPanels } from "./resolve.js"

export async function getCreateNestedPanelsPrompts(inquirer) {
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

  return resolveCreateNestedPanels({ choosenPath, newPanelName })
}
