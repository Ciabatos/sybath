import fs from "fs"
import path from "path"
import { toCamelCase, toPascalCase } from "./helpers/helpers.js"

const COMPONENTS_ROOT = path.resolve("methods/hooks")

export default function createAtomClientSingleton(plop) {
  const generatorName = "createAtomClientSingleton"
  plop.setGenerator(generatorName, {
    description: "Create new atom client singleton to preserve state between panels",
    prompts: [
      {
        type: "list",
        name: "choosenPath",
        message: "Wybierz folder w hooks",
        choices: fs
          .readdirSync(COMPONENTS_ROOT)
          .filter((f) => fs.statSync(path.join(COMPONENTS_ROOT, f)).isDirectory()),
      },
      {
        type: "input",
        name: "inputName",
        message: "Atom name without extension Atom",
      },
    ],

    actions(data) {
      const actions = []

      const atomName = data.inputName + "Atom"

      data.inputName = data.inputName
      data.atomName = atomName

      data.inputCamelName = toCamelCase(data.inputName)
      data.inputPascalName = toPascalCase(data.inputName)
      data.atomCamelName = toCamelCase(data.atomName)
      data.atomPascalName = toPascalCase(data.atomName)
      data.generatorName = generatorName

      data.filesCreated = [
        `store/atoms/client/${data.atomName}.ts`,
        `/methods/hooks/${data.choosenPath}/composite/use${data.inputPascalName}.ts`,
        `answerHistory/createAtomClientSingleton/${data.atomName}_answers.json`,
      ]

      data.dateCreated = new Date().toISOString()

      actions.push(
        {
          type: "add",
          path: "../store/atoms/client/{{atomCamelName}}.ts",
          templateFile: "plop-templates/createAtomClientSingleton/atomCreateAtomClientSingleton.hbs",
          force: true,
        },
        {
          type: "add",
          path: "../methods/hooks/{{choosenPath}}/composite/use{{inputPascalName}}.ts",
          templateFile: "plop-templates/createAtomClientSingleton/hookCreateAtomClientSingleton.hbs",
          force: true,
        },
        {
          type: "add",
          path: "./answerHistory/createAtomClientSingleton/{{atomCamelName}}_answers.json",
          templateFile: "plop-templates/answerHistory.hbs",
          force: true,
        },
      )

      return actions
    },
  })
}
