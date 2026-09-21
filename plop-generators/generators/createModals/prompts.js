import { resolveCreateModals } from "./resolve.js"

export async function getCreateModalsPrompts(inquirer) {
  const { modalName } = await inquirer.prompt([
    {
      type: "input",
      name: "modalName",
      message:
        "Modal name without extension, suffix or prefixes, should start with Modal word and later position on monitor",
    },
  ])

  return resolveCreateModals({ modalName })
}
