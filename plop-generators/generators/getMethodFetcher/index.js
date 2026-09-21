import { getMethodFetcherActions } from "./actions.js"
import { getMethodFetcherPrompts } from "./prompts.js"
import { resolveGetMethodFetcher } from "./resolve.js"

export { getMethodFetcherActions, getMethodFetcherPrompts, resolveGetMethodFetcher }

export default function getMethodFetcher(plop) {
  plop.setGenerator("getMethodFetcher", {
    description: "Generate fetcher from Postgres method",
    prompts: getMethodFetcherPrompts,
    actions: getMethodFetcherActions(),
  })
}
