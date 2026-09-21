import { getTableActions } from "../getTable/actions.js"
import { resolveGetTable } from "../getTable/resolve.js"

import { getMethodFetcherActions } from "../getMethodFetcher/actions.js"
import { resolveGetMethodFetcher } from "../getMethodFetcher/resolve.js"

import { getMethodActionActions } from "../getMethodAction/actions.js"
import { resolveGetMethodAction } from "../getMethodAction/resolve.js"

/**
 * Jedno miejsce, w którym rejestrujesz generator.
 * Dodanie nowego generatora = jeden wpis tutaj.
 */
export const GENERATORS = {
  getTable: {
    resolve: resolveGetTable,
    actions: getTableActions,
  },
  getMethodFetcher: {
    resolve: resolveGetMethodFetcher,
    actions: getMethodFetcherActions,
  },
  getMethodAction: {
    resolve: resolveGetMethodAction,
    actions: getMethodActionActions,
  },
}
