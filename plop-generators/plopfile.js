import createAtomClientSingleton from "./generators/createAtomClientSingleton/index.js"
import createButton from "./generators/createButton/index.js"
import createListPanels from "./generators/createListPanels/index.js"
import createModals from "./generators/createModals/index.js"
import createNestedPanels from "./generators/createNestedPanels/index.js"
import createPanels from "./generators/createPanels/index.js"
import formatPrettier from "./generators/formatPrettier/index.js"
import getMethodAction from "./generators/getMethodAction/index.js"
import getMethodFetcher from "./generators/getMethodFetcher/index.js"
import getTable from "./generators/getTable/index.js"
import replayHistory from "./generators/replayHistory/index.js"
import rollback from "./generators/rollback/index.js"

async function configurePlop(plop) {
  plop.setHelper("json", (context) => JSON.stringify(context, null, 2))

  createPanels(plop)
  createListPanels(plop)
  createNestedPanels(plop)
  createButton(plop)
  createModals(plop)
  createAtomClientSingleton(plop)
  getMethodAction(plop)
  getMethodFetcher(plop)
  getTable(plop)
  rollback(plop)
  replayHistory(plop)
  formatPrettier(plop)
}

export default configurePlop
