import { getTableActions } from "./actions.js"
import { getTablePrompts } from "./prompts.js"
import { resolveGetTable } from "./resolve.js"

export { getTableActions, getTablePrompts, resolveGetTable }

export default function getTable(plop) {
  plop.setGenerator("getTable", {
    description: "Generate fetchers from Postgres table",
    prompts: getTablePrompts,
    actions: getTableActions(),
  })
}
