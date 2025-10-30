import { NodePlopAPI } from "plop"
import { getTablePrompts } from "./prompts"
import { getTableActions } from "./actions"

export default function tableGenerator(plop: NodePlopAPI) {
  plop.setGenerator("Get Table", {
    description: "Generate TypeScript types and fetcher from Postgres table",
    prompts: getTablePrompts,
    actions: getTableActions,
  })
}
