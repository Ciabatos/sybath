import fs from "fs"
import path from "path"

const COMPONENTS_ROOT = path.resolve("components")

export default function createNestedPanels(plop) {
  const generatorName = "createNestedPanels"
  plop.setGenerator(generatorName, {
    description: "Create new nested panels",
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

      data.generatorName = generatorName

      data.filesCreated = [
        `components/${data.choosenPath}/${data.newPanelName}.tsx`,
        `components/${data.choosenPath}/styles/${data.newPanelName}.module.css`,
      ]

      data.dateCreated = new Date().toISOString()

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
        {
          type: "add",
          path: "./answerHistory/createNestedPanels/{{newPanelName}}_answers.json",
          templateFile: "plop-templates/answerHistory.hbs",
          force: true,
        },
      )
      return actions
    },
  })
}
