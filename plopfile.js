const getTable = require("./plop-generators/getTable")

module.exports = function (plop) {
  plop.setHelper("eq", (a, b) => a === b)


  getTable(plop)

}
