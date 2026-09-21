import { toCamelCase, toPascalCase } from "../../helpers/helpers.js"

export function resolveCreateModals({ modalName }) {
  const modalCamelName = toCamelCase(modalName)
  const modalPascalName = toPascalCase(modalName)
  const positionPascalName = toPascalCase(modalName.replace(/^Modal/, ""))

  return {
    modalName,
    modalCamelName,
    modalPascalName,
    positionPascalName,
    generatorName: "createModals",
    filesCreated: [
      `store/atoms/createModals/${modalCamelName}Atom.ts`,
      `methods/hooks/modals/use${modalPascalName}.ts`,
      `components/modals/${modalPascalName}.tsx`,
      `.vscode/${modalPascalName}.code-snippets`,
      `components/modals/styles/${modalPascalName}.module.css`,
    ],
    dateCreated: new Date().toISOString(),
  }
}
