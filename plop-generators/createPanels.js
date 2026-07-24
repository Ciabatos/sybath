import fs from "fs"
import path from "path"

const MAIN_ROOT = path.resolve("types/enumeration")
const COMPONENTS_ROOT = path.resolve("components")

export default function createPanels(plop) {
  const generatorName = "createPanels"
  plop.setGenerator(generatorName, {
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
        type: "list",
        name: "enumeration",
        message: "Select modal to render the panels",
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

      const enumFileName = data.enumeration
      const enumName = enumFileName.replace(/\.ts$/, "")
      const enumSuffix = enumName.replace(/^EPanels/, "")
      const panelName = `panel${enumSuffix}`

      data.enumName = enumName
      data.enumSuffix = enumSuffix
      data.panelName = panelName
      data.generatorName = generatorName

      data.filesCreated = [
        `components/${data.choosenPath}/${data.newPanelName}.tsx`,
        `components/${data.choosenPath}/styles/${data.newPanelName}.module.css`,
        `types/panels/${data.panelName}/${data.newPanelName}.txt`,
      ]

      data.dateCreated = new Date().toISOString()

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
        {
          type: "add",
          path: `../types/panels/{{panelName}}/{{newPanelName}}.txt`,
          templateFile: "plop-templates/createPanels/panelType.hbs",
          force: true,
        },
        {
          type: "add",
          path: "./answerHistory/createPanels/{{newPanelName}}_answers.json",
          templateFile: "plop-templates/answerHistory.hbs",
          force: true,
        },
      )

      return actions
    },
  })
}
