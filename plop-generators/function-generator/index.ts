import { NodePlopAPI } from "plop"
import { getFunctionPrompts } from "./prompts"
import { getFunctionActions } from "./actions"

export default function functionGenerator(plop: NodePlopAPI) {
  plop.setGenerator("Get Function", {
    description: "Generate TS async function from Postgres function",
    prompts: getFunctionPrompts,
    actions: getFunctionActions,
  })
}
