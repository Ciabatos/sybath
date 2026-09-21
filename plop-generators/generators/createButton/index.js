import { getCreateButtonActions } from "./actions.js"
import { getCreateButtonPrompts } from "./prompts.js"
import { resolveCreateButton } from "./resolve.js"

export { getCreateButtonActions, getCreateButtonPrompts, resolveCreateButton }

export default function createButton(plop) {
  plop.setGenerator("createButton", {
    description: "Create Button",
    prompts: getCreateButtonPrompts,
    actions: getCreateButtonActions(),
  })
}
