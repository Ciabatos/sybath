export function getTableActions() {
  return [
    {
      type: "add",
      path: "../db/postgresMainDatabase/schemas/{{schema}}/{{entityCamelName}}.ts",
      templateFile: "plop-templates/getTable/dbGetTable.hbs",
      force: true,
    },
    { type: "add", path: "../{{apiPath}}", templateFile: "plop-templates/getTable/apiGetTable.hbs", force: true },
    {
      type: "add",
      path: "../{{apiPathByKey}}",
      templateFile: "plop-templates/getTable/apiGetTableByKey.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/hooks/{{schema}}/core/useFetch{{schemaEntityPascalName}}.ts",
      templateFile: "plop-templates/getTable/hookGetTable.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/hooks/{{schema}}/core/useFetch{{schemaEntityPascalName}}ByKey.ts",
      templateFile: "plop-templates/getTable/hookGetTableByKey.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/server-fetchers/{{schema}}/core/get{{schemaEntityPascalName}}Server.ts",
      templateFile: "plop-templates/getTable/hookGetTableServer.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/server-fetchers/{{schema}}/core/get{{schemaEntityPascalName}}ByKeyServer.ts",
      templateFile: "plop-templates/getTable/hookGetTableByKeyServer.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/services/{{schema}}/{{fetcherName}}Service.ts",
      templateFile: "plop-templates/getTable/serviceGetTable.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/services/{{schema}}/{{fetcherByKeyName}}Service.ts",
      templateFile: "plop-templates/getTable/serviceGetTableByKey.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../store/atoms/getTable/{{entityCamelName}}Atom.ts",
      templateFile: "plop-templates/getTable/atomGetTable.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../.vscode/use{{schemaEntityPascalName}}.code-snippets",
      templateFile: "plop-templates/getTable/snippetHookTable.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../.vscode/use{{schemaEntityPascalName}}ByKey.code-snippets",
      templateFile: "plop-templates/getTable/snippetHookTableByKey.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/hooks/{{schema}}/core/useMutate{{schemaEntityPascalName}}.ts",
      templateFile: "plop-templates/getTable/hookMutateTable.hbs",
      force: true,
      skip(answers) {
        return answers.generateMutation ? false : "Pomijam generowanie useMutate..."
      },
    },
    {
      type: "add",
      path: "../methods/hooks/{{schema}}/core/useMutate{{schemaEntityPascalName}}ByKey.ts",
      templateFile: "plop-templates/getTable/hookMutateTableByKey.hbs",
      force: true,
      skip(answers) {
        return answers.generateMutation ? false : "Pomijam generowanie useMutate..."
      },
    },
    {
      type: "add",
      path: "./answerHistory/getTable/{{schema}}_{{table}}_answers.json",
      templateFile: "plop-templates/answerHistory.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/hooks/{{schema}}/core/useFetch{{schemaEntityPascalName}}.md",
      templateFile: "plop-templates/getTable/skillCreatorTable.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/hooks/{{schema}}/core/useFetch{{schemaEntityPascalName}}ByKey.md",
      templateFile: "plop-templates/getTable/skillCreatorTableByKey.hbs",
      force: true,
    },
    { type: "PrettierFormat" },
  ]
}
