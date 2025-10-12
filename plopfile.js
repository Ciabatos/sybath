import getFunction from "./plop-generators/getFunction.js"
import getTable from "./plop-generators/getTable.js"

function configurePlop(plop) {
  plop.setHelper("eq", (a, b) => a === b)

  getTable(plop)
  getFunction(plop)
}

export default configurePlop
