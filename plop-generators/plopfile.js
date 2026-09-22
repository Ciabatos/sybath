import getMethodAction from "./generators/getMethodAction/index.js"

async function configurePlop(plop) {
  plop.setHelper("json", (context) => JSON.stringify(context, null, 2))

  // createPanels(plop)
  // createListPanels(plop)
  // createNestedPanels(plop)
  // createButton(plop)
  // createModals(plop)
  // createAtomClientSingleton(plop)
  getMethodAction(plop)
  // getMethodFetcher(plop)
  // getTable(plop)
  // rollback(plop)
  // replayHistory(plop)
  // formatPrettier(plop)
}

export default configurePlop
