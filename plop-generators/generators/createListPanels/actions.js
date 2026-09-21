export function getCreateListPanelsActions() {
  return () => [
    {
      type: "add",
      path: "../components/{{choosenPath}}/{{newPanelName}}.tsx",
      templateFile: "plop-templates/createListPanels/panel.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../components/{{choosenPath}}/styles/{{newPanelName}}.module.css",
      templateFile: "plop-templates/createListPanels/panelStyle.hbs",
      force: true,
    },
    {
      type: "add",
      path: "./answerHistory/createListPanels/{{newPanelName}}_answers.json",
      templateFile: "plop-templates/answerHistory.hbs",
      force: true,
    },
  ]
}
