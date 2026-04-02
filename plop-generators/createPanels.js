import fs from "fs"
import path from "path"

const MAIN_ROOT = path.resolve("types/enumeration")
const COMPONENTS_ROOT = path.resolve("components")

export default function createPanels(plop) {
  plop.setGenerator("createPanels", {
    description: "Create new panel",
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
      {
        type: "checkbox",
        name: "enumeration",
        message: "Select modals to render the panels",
        choices: fs.readdirSync(MAIN_ROOT).filter((f) => fs.statSync(path.join(MAIN_ROOT, f)).isFile()),
        validate: (answer) => {
          if (answer.length < 1) {
            return "Musisz wybrać przynajmniej jeden modal."
          }
          return true
        },
      },
    ],

    actions(data) {
      const actions = []

      actions.push(
        {
          type: "add",
          path: "../components/{{choosenPath}}/{{newPanelName}}.tsx",
          templateFile: "plop-templates/createPanels/panel.hbs",
          force: true,
        },
        {
          type: "add",
          path: "../components/{{choosenPath}}/styles/{{newPanelName}}.module.css",
          templateFile: "plop-templates/createPanels/panelStyle.hbs",
          force: true,
        },
      )

      data.enumeration.forEach((enumFileName) => {
        const enumName = enumFileName.replace(/\.ts$/, "")
        const enumSuffix = enumName.replace(/^EPanels/, "")
        const panelName = `panel${enumSuffix}`

        actions.push({
          type: "modify",
          path: `../types/enumeration/${enumFileName}`,
          pattern: new RegExp(`(export enum ${enumName}\\s*\\{[\\s\\S]*?)(\\n\\})`),
          template: `$1
  {{newPanelName}} = "{{newPanelName}}",$2`,
        })

        actions.push({
          type: "modify",
          path: `../types/panels/${panelName}.ts`,
          pattern: new RegExp(`(export const ${panelName}[\\s\\S]*?=\\s*\\{[\\s\\S]*?)(\\n\\s*\\})`),
          template: `$1
  [${enumName}.{{newPanelName}}]: React.lazy(() => import("@/components/{{choosenPath}}/{{newPanelName}}")),$2`,
        })
      })

      return actions
    },
  })
}
