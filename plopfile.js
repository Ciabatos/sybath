import getMethodAction from "./plop-generators/getMethodAction.js"
import getMethodFetcher from "./plop-generators/getMethodFetcher.js"
import getTable from "./plop-generators/getTable.js"

function configurePlop(plop) {
  plop.setHelper("eq", (a, b) => a === b)

  getMethodAction(plop)
  getMethodFetcher(plop)
  getTable(plop)
}

export default configurePlop
