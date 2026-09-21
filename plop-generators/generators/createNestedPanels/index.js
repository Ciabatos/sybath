import { getCreateNestedPanelsActions } from "./actions.js"
import { getCreateNestedPanelsPrompts } from "./prompts.js"
import { resolveCreateNestedPanels } from "./resolve.js"

export { getCreateNestedPanelsActions, getCreateNestedPanelsPrompts, resolveCreateNestedPanels }

export default function createNestedPanels(plop) {
  plop.setGenerator("createNestedPanels", {
    description: "Create new nested ELELEMENT who can be used to be nested in MAIN Panel",
    prompts: getCreateNestedPanelsPrompts,
    actions: getCreateNestedPanelsActions(),
  })
}
