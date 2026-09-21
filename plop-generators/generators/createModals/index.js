import { getCreateModalsActions } from "./actions.js"
import { getCreateModalsPrompts } from "./prompts.js"
import { resolveCreateModals } from "./resolve.js"

export { getCreateModalsActions, getCreateModalsPrompts, resolveCreateModals }

export default function createModals(plop) {
  plop.setGenerator("createModals", {
    description: "Create new modal",
    prompts: getCreateModalsPrompts,
    actions: getCreateModalsActions(),
  })
}
