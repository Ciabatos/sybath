export function resolveCreateNestedPanels({ choosenPath, newPanelName }) {
  return {
    choosenPath,
    newPanelName,
    generatorName: "createNestedPanels",
    filesCreated: [
      `components/${choosenPath}/${newPanelName}.tsx`,
      `components/${choosenPath}/styles/${newPanelName}.module.css`,
    ],
    dateCreated: new Date().toISOString(),
  }
}
