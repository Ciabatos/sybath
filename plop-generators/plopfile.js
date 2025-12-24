import getMethodAction from "./getMethodAction.js"
import getMethodFetcher from "./getMethodFetcher.js"
import getTable from "./getTable.js"
import { formatWithPrettier } from "./helpers/prettier.js"
import replayHistory from "./replayHistory.js"

function configurePlop(plop) {
  const pathsToFormat = [
    "store/atoms.ts",
    "db/postgresMainDatabase/schemas",
    "app/api",
    "methods/hooks",
    "methods/server-fetchers",
    "methods/services",
    "methods/actions",
  ]

  plop.setHelper("eq", (a, b) => a === b)

  plop.setHelper("json", (context) => JSON.stringify(context, null, 2))

  plop.setActionType("PrettierFormat", async function () {
    try {
      const result = await formatWithPrettier(pathsToFormat)
      return result
    } catch (err) {
      console.error("Prettier failed:", err)
      throw err
    }
  })

  getMethodAction(plop)

  getMethodFetcher(plop)

  getTable(plop)

  replayHistory(plop)
}

export default configurePlop
