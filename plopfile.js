const getTable = require("./plop-generators/getTable")
const getProcedure = require("./plop-generators/getProcedure")

module.exports = function (plop) {
  plop.setHelper("eq", (a, b) => a === b)


  getTable(plop)
  getProcedure(plop)
}
