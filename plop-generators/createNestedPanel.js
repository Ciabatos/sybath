import fs from "fs"
import path from "path"

const COMPONENTS_ROOT = path.resolve("components")

export default function createNestedPanel(plop) {
  plop.setGenerator("createNestedPanel", {
    description: "Create new nested panel",
    prompts: [
      {
        type: "list",
        name: "choosenPath",
        message: "Wybierz folder w components",
        choices: fs
          .readdirSync(COMPONENTS_ROOT)
          .filter((f) => fs.statSync(path.join(COMPONENTS_ROOT, f)).isDirectory()),
      },
      {
        type: "input",
        name: "newPanelName",
        message: "Panel name without .tsx extension :",
      },
    ],

    actions(data) {
      const actions = []

      actions.push(
        {
          type: "add",
          path: "../components/{{choosenPath}}/{{newPanelName}}.tsx",
          templateFile: "plop-templates/createNestedPanels/panel.hbs",
          force: true,
        },
        {
          type: "add",
          path: "../components/{{choosenPath}}/styles/{{newPanelName}}.module.css",
          templateFile: "plop-templates/createNestedPanels/panelStyle.hbs",
          force: true,
        },
      )
      return actions
    },
  })
}
