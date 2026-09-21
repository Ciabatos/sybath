export function getMethodFetcherActions() {
  return [
    {
      type: "add",
      path: "../db/postgresMainDatabase/schemas/{{schema}}/{{entityCamelName}}.ts",
      templateFile: "plop-templates/methodFetcher/dbGetMethodFetcher.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../{{apiPath}}",
      templateFile: "plop-templates/methodFetcher/apiGetMethodFetcher.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/hooks/{{schema}}/core/useFetch{{entityPascalName}}.ts",
      templateFile: "plop-templates/methodFetcher/hookGetMethodFetcher.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/server-fetchers/{{schema}}/core/{{dbFunctionName}}Server.ts",
      templateFile: "plop-templates/methodFetcher/hookGetMethodFetcherServer.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/services/{{schema}}/fetch{{entityPascalName}}Service.ts",
      templateFile: "plop-templates/methodFetcher/serviceGetMethodFetcher.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../store/atoms/getMethodFetcher/{{entityCamelName}}Atom.ts",
      templateFile: "plop-templates/methodFetcher/atomMethodFetcher.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../.vscode/use{{entityPascalName}}.code-snippets",
      templateFile: "plop-templates/methodFetcher/snippetHookMethod.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/hooks/{{schema}}/core/useMutate{{entityPascalName}}.ts",
      templateFile: "plop-templates/methodFetcher/hookMutateMethodFetcher.hbs",
      force: true,
      skip(answers) {
        return answers.generateMutation ? false : "Pomijam generowanie useMutate..."
      },
    },
    {
      type: "add",
      path: "./answerHistory/getMethodFetcher/{{schema}}_{{method}}_answers.json",
      templateFile: "plop-templates/answerHistory.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../methods/hooks/{{schema}}/core/useFetch{{entityPascalName}}.md",
      templateFile: "plop-templates/methodFetcher/skillCreatorMethod.hbs",
      force: true,
    },
    { type: "PrettierFormat" },
  ]
}
