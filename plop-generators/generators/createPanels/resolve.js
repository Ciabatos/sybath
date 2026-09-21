export function resolveCreatePanels({ choosenPath, newPanelName, enumeration }) {
  const enumFileName = enumeration
  const enumName = enumFileName.replace(/\.ts$/, "")
  const enumSuffix = enumName.replace(/^EPanels/, "")
  const panelName = `panel${enumSuffix}`

  return {
    choosenPath,
    newPanelName,
    enumeration,
    enumName,
    enumSuffix,
    panelName,
    generatorName: "createPanels",
    filesCreated: [
      `components/${choosenPath}/${newPanelName}.tsx`,
      `components/${choosenPath}/styles/${newPanelName}.module.css`,
      `types/panels/${panelName}/${newPanelName}.txt`,
    ],
    dateCreated: new Date().toISOString(),
  }
}
