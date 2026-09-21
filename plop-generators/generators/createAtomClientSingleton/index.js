import { getCreateAtomClientSingletonActions } from "./actions.js"
import { getCreateAtomClientSingletonPrompts } from "./prompts.js"
import { resolveCreateAtomClientSingleton } from "./resolve.js"

export { getCreateAtomClientSingletonActions, getCreateAtomClientSingletonPrompts, resolveCreateAtomClientSingleton }

export default function createAtomClientSingleton(plop) {
  plop.setGenerator("createAtomClientSingleton", {
    description: "Create new atom client singleton to preserve state between panels",
    prompts: getCreateAtomClientSingletonPrompts,
    actions: getCreateAtomClientSingletonActions(),
  })
}
