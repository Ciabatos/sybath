export function getCreatePanelsActions() {
  return () => [
    {
      type: "add",
      path: "../components/{{choosenPath}}/{{newPanelName}}.tsx",
      templateFile: "plop-templates/createPanels/panel.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../components/{{choosenPath}}/styles/{{newPanelName}}.module.css",
      templateFile: "plop-templates/createPanels/panelStyle.hbs",
      force: true,
    },
    {
      type: "add",
      path: `../types/panels/{{panelName}}/{{newPanelName}}.txt`,
      templateFile: "plop-templates/createPanels/panelType.hbs",
      force: true,
    },
    {
      type: "add",
      path: "./answerHistory/createPanels/{{newPanelName}}_answers.json",
      templateFile: "plop-templates/answerHistory.hbs",
      force: true,
    },
  ]
}
