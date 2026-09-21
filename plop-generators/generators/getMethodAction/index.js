import { getMethodActionActions } from "./actions.js"
import { getMethodActionPrompts } from "./prompts.js"
import { resolveGetMethodAction } from "./resolve.js"

export { getMethodActionActions, getMethodActionPrompts, resolveGetMethodAction }

export default function getMethodAction(plop) {
  plop.setGenerator("getMethodAction", {
    description: "Generate action from Postgres method",
    prompts: getMethodActionPrompts,
    actions: getMethodActionActions(),
  })
}
