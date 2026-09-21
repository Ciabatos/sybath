export function getCreateButtonActions() {
  return () => [
    {
      type: "add",
      path: "../components/{{choosenPath}}/{{newPanelName}}.tsx",
      templateFile: "plop-templates/createButton/panel.hbs",
      force: true,
    },
    {
      type: "add",
      path: "../components/{{choosenPath}}/styles/{{newPanelName}}.module.css",
      templateFile: "plop-templates/createButton/panelStyle.hbs",
      force: true,
    },
    {
      type: "add",
      path: "./answerHistory/createButton/{{newPanelName}}_answers.json",
      templateFile: "plop-templates/answerHistory.hbs",
      force: true,
    },
  ]
}
