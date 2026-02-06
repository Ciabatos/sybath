import fs from "fs"
import path from "path"

const MAIN_ROOT = path.resolve("types/enumeration")

export default function createPanels(plop) {
  plop.setGenerator("createPanels", {
    description: "Create new panel",
    prompts: [
      {
        type: "input",
        name: "newPanelName",
        message: "Panel name",
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
          path: "../components/panels/{{newPanelName}}.tsx",
          templateFile: "plop-templates/createPanels/panel.hbs",
          force: true,
        },
        {
          type: "add",
          path: "../components/panels/styles/{{newPanelName}}.module.css",
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
          pattern: new RegExp(`(export const ${panelName}[\\s\\S]*?=\\s*\\{[\\s\\S]*?)(\\n\\})`),
          template: `$1
  [${enumName}.{{newPanelName}}]: React.lazy(() => import("@/components/panels/{{newPanelName}}")),$2`,
        })
      })

      return actions
    },
  })
}
