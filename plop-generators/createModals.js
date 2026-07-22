import { snakeToCamel, snakeToPascal } from "./helpers/helpers.js"

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

      data.modalCamelName = snakeToCamel(data.modalName)
      data.modalPascalName = snakeToPascal(data.modalName)

      const position = data.modalPascalName.replace(/^Modal/, "")
      data.positionPascalName = snakeToPascal(position)

      data.generatorName = generatorName

      data.filesCreated = [
        `store/atoms/${data.modalCamelName}Atom.ts`,
        `types/enumeration/EPanels${data.positionPascalName}.ts`,
        `methods/hooks/modals/use${data.modalPascalName}.ts`,
        `components/modals/${data.modalPascalName}.tsx`,
        `types/panels/panel${data.positionPascalName}.ts`,
        `.vscode/snippets/${data.modalPascalName}.code-snippets`,
      ]

      data.dateCreated = new Date().toISOString()

      actions.push(
        {
          type: "add",
          path: "../store/atoms/{{modalCamelName}}Atom.ts",
          templateFile: "plop-templates/createModal/atomCreateModal.hbs",
          force: true,
        },
        {
          type: "add",
          path: `../types/enumeration/EPanels{{positionPascalName}}.ts`,
          templateFile: "plop-templates/createModal/enumCreateModal.hbs",
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
          path: `../types/panels/panel{{positionPascalName}}.ts`,
          templateFile: "plop-templates/createModal/panelCreateModal.hbs",
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
