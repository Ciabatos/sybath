export function getCreateModalsActions() {
  return () => [
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
      path: "../components/modals/styles/{{modalPascalName}}.module.css",
      templateFile: "plop-templates/createModal/stylesCreateModal.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../.vscode/{{modalPascalName}}.code-snippets",
      templateFile: "plop-templates/createModal/snippetCreateModal.hbs",
      force: true,
    },
    {
      type: "add",
      path: "./answerHistory/createModals/{{modalPascalName}}_answers.json",
      templateFile: "plop-templates/answerHistory.hbs",
      force: true,
    },
  ]
}
