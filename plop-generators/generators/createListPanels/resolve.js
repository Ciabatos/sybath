export function resolveCreateListPanels({ choosenPath, newPanelName }) {
  return {
    choosenPath,
    newPanelName,
    generatorName: "createListPanels",
    filesCreated: [
      `components/${choosenPath}/${newPanelName}.tsx`,
      `components/${choosenPath}/styles/${newPanelName}.module.css`,
    ],
    dateCreated: new Date().toISOString(),
  }
}
