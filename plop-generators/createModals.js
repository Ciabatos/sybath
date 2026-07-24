import { toCamelCase, toPascalCase } from "./helpers/helpers.js"

export default function createModals(plop) {
  const generatorName = "createModals"
  plop.setGenerator(generatorName, {
    description: "Create new modal",
    prompts: [
      {
        type: "input",
        name: "modalName",
        message:
          "Modal name without extension, suffix or prefixes, should start with Modal word and later position on monitor",
      },
    ],

    actions(data) {
      const actions = []

      data.modalCamelName = toCamelCase(data.modalName)
      data.modalPascalName = toPascalCase(data.modalName)

      const position = data.modalName.replace(/^Modal/, "")
      data.positionPascalName = toPascalCase(position)

      data.generatorName = generatorName

      data.filesCreated = [
        `store/atoms/createModals/${data.modalCamelName}Atom.ts`,
        `methods/hooks/modals/use${data.modalPascalName}.ts`,
        `components/modals/${data.modalPascalName}.tsx`,
        `types/panels/${data.positionPascalName}/Inactive.txt`,
        `.vscode/snippets/${data.modalPascalName}.code-snippets`,
        `components/modals/styles/${data.modalPascalName}.module.css`,
      ]

      data.dateCreated = new Date().toISOString()

      actions.push(
        {
          type: "add",
          path: "../store/atoms/createModals/{{modalCamelName}}Atom.ts",
          templateFile: "plop-templates/createModal/atomCreateModal.hbs",
          force: true,
        },
        {
          type: "add",
          path: "../methods/hooks/modals/use{{modalPascalName}}.ts",
          templateFile: "plop-templates/createModal/hookCreateModal.hbs",
          force: true,
        },
        {
          type: "add",
          path: "../components/modals/{{modalPascalName}}.tsx",
          templateFile: "plop-templates/createModal/modalCreateModal.hbs",
          force: true,
        },
        {
          type: "add",
          path: `../types/panels/panel{{positionPascalName}}/Inactive.txt`,
          templateFile: "plop-templates/createModal/panelCreateModal.hbs",
          force: true,
        },
        {
          type: "add",
          path: "../components/modals/styles/{{modalPascalName}}.module.css",
          templateFile: "plop-templates/createModal/stylesCreateModal.hbs",
          force: true,
        },
        {
          type: "add",
          path: "../.vscode/snippets/{{modalPascalName}}.code-snippets",
          templateFile: "plop-templates/createModal/snippetCreateModal.hbs",
          force: true,
        },
        {
          type: "add",
          path: "./answerHistory/createModals/{{modalPascalName}}_answers.json",
          templateFile: "plop-templates/answerHistory.hbs",
          force: true,
        },
      )

      return actions
    },
  })
}
