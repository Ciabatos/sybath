export function getCreateNestedPanelsActions() {
  return () => [
    {
      type: "add",
      path: "../components/{{choosenPath}}/{{newPanelName}}.tsx",
      templateFile: "plop-templates/createNestedPanels/panel.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../components/{{choosenPath}}/styles/{{newPanelName}}.module.css",
      templateFile: "plop-templates/createNestedPanels/panelStyle.hbs",
      force: true,
    },
    {
      type: "add",
      path: "./answerHistory/createNestedPanels/{{newPanelName}}_answers.json",
      templateFile: "plop-templates/answerHistory.hbs",
      force: true,
    },
  ]
}
