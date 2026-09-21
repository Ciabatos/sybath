import { toCamelCase, toPascalCase } from "../../helpers/helpers.js"

export function resolveCreateAtomClientSingleton({ choosenPath, inputName }) {
  const atomName = inputName + "Atom"

  const inputCamelName = toCamelCase(inputName)
  const inputPascalName = toPascalCase(inputName)
  const atomCamelName = toCamelCase(atomName)
  const atomPascalName = toPascalCase(atomName)

  return {
    choosenPath,
    inputName,
    atomName,
    inputCamelName,
    inputPascalName,
    atomCamelName,
    atomPascalName,
    generatorName: "createAtomClientSingleton",
    filesCreated: [
      `store/atoms/client/${atomName}.ts`,
      `methods/hooks/${choosenPath}/composite/use${inputPascalName}.ts`,
      `answerHistory/createAtomClientSingleton/${atomName}_answers.json`,
    ],
    dateCreated: new Date().toISOString(),
  }
}
