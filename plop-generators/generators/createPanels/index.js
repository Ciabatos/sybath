import { getCreatePanelsActions } from "./actions.js"
import { getCreatePanelsPrompts } from "./prompts.js"
import { resolveCreatePanels } from "./resolve.js"

export { getCreatePanelsActions, getCreatePanelsPrompts, resolveCreatePanels }

export default function createPanels(plop) {
  plop.setGenerator("createPanels", {
    description: "Create new MAIN panel",
    prompts: getCreatePanelsPrompts,
    actions: getCreatePanelsActions(),
  })
}
