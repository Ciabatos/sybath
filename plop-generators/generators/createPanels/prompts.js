import { listComponentsFolders, listEnumerationFiles } from "../../helpers/targets.js"
import { resolveCreatePanels } from "./resolve.js"

export async function getCreatePanelsPrompts(inquirer) {
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

  const { enumeration } = await inquirer.prompt([
    {
      type: "list",
      name: "enumeration",
      message: "Select modal to render the panels",
      choices: listEnumerationFiles(),
      validate: (answer) => (answer.length < 1 ? "Musisz wybrać przynajmniej jeden modal." : true),
    },
  ])

  return resolveCreatePanels({ choosenPath, newPanelName, enumeration })
}
