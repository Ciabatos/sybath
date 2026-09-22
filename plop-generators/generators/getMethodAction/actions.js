export function getMethodActionActions() {
  return [
    {
      type: "add",
      path: "../methods/actions/{{schema}}/{{actionName}}.ts",
      templateFile: "plop-templates/methodAction/actionGetMethodAction.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/actions/{{schema}}/{{actionName}}.md",
      templateFile: "plop-templates/methodAction/skillCreatorAction.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../db/postgresMainDatabase/schemas/{{schema}}/{{entityCamelName}}.ts",
      templateFile: "plop-templates/methodAction/dbGetMethodAction.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/services/{{schema}}/{{entityCamelName}}Service.ts",
      templateFile: "plop-templates/methodAction/serviceGetMethodAction.hbs",
      force: true,
    },
    {
      type: "add",
      path: "./answerHistory/getMethodAction/{{schema}}_{{method}}_answers.json",
      templateFile: "plop-templates/answerHistory.hbs",
      force: true,
    },
    // { type: "PrettierFormat" },
  ]
}
