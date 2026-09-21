import { formatWithPrettier } from "../../helpers/prettier.js"
import { getFormatPrettierActions } from "./actions.js"
import { getFormatPrettierPrompts } from "./prompts.js"
import { DEFAULT_TARGET_DIRS, resolvePathsToFormat } from "./resolve.js"

export { DEFAULT_TARGET_DIRS, getFormatPrettierActions, getFormatPrettierPrompts, resolvePathsToFormat }

export default function formatPrettier(plop) {
  // Rejestracja action type — używana przez ten generator ORAZ przez
  // getTable / getMethodFetcher / getMethodAction / replayHistory, które
  // na końcu swoich akcji mają { type: "PrettierFormat" }.
  plop.setActionType("PrettierFormat", async (_answers, config) => {
    // Jeśli ktoś podał config.paths — użyj ich (selektywne formatowanie).
    // W przeciwnym razie — zawsze cały DEFAULT_TARGET_DIRS.
    const paths = Array.isArray(config?.paths) && config.paths.length > 0 ? config.paths : resolvePathsToFormat()

    if (paths.length === 0) {
      return "No paths to format"
    }

    try {
      const result = await formatWithPrettier(paths)
      return result
    } catch (err) {
      console.error("Prettier failed:", err)
      throw err
    }
  })

  plop.setGenerator("formatPrettier", {
    description: "Format code with Prettier (always whole DEFAULT_TARGET_DIRS)",
    prompts: getFormatPrettierPrompts,
    actions: getFormatPrettierActions(),
  })
}
