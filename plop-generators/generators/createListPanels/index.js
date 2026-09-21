import { getCreateListPanelsActions } from "./actions.js"
import { getCreateListPanelsPrompts } from "./prompts.js"
import { resolveCreateListPanels } from "./resolve.js"

export { getCreateListPanelsActions, getCreateListPanelsPrompts, resolveCreateListPanels }

export default function createListPanels(plop) {
  plop.setGenerator("createListPanels", {
    description: "Create new ELEMENT of the list with are used in panels",
    prompts: getCreateListPanelsPrompts,
    actions: getCreateListPanelsActions(),
  })
}
