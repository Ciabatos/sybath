import getProcedure from "./plop-generators/getProcedure.js"
import getTable from "./plop-generators/getTable.js"

function configurePlop(plop) {
  plop.setHelper("eq", (a, b) => a === b)

  getTable(plop)
  getProcedure(plop)
}

export default configurePlop
