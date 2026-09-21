export function getCreateAtomClientSingletonActions() {
  return () => [
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
  ]
}
