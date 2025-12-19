import getMethodAction from "./plop-generators/getMethodAction.js"
import getMethodFetcher from "./plop-generators/getMethodFetcher.js"
import getTable from "./plop-generators/getTable.js"
import { formatWithPrettier } from "./plop-generators/helpers/prettier.js"

function configurePlop(plop) {
  const pathsToFormat = [
    "store/atoms.ts",
    "db/postgresMainDatabase/schemas",
    "app/api",
    "methods/hooks",
    "methods/server-fetchers",
  ]

  plop.setHelper("eq", (a, b) => a === b)

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
}

export default configurePlop
