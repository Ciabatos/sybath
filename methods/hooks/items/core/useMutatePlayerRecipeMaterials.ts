// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerRecipeMaterialsRecordById,
  TPlayerRecipeMaterialsFetchParams,
  TPlayerRecipeMaterials,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipeMaterials"
import { PLAYERRECIPEMATERIALS_SWR_KEY } from "@/methods/hooks/items/core/useFetchPlayerRecipeMaterials"
import { playerRecipeMaterialsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerRecipeMaterials(params: TPlayerRecipeMaterialsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = PLAYERRECIPEMATERIALS_SWR_KEY(params)
  const playerRecipeMaterials = useAtomValue(playerRecipeMaterialsAtom)

  function mutatePlayerRecipeMaterials(optimisticParams?: Partial<TPlayerRecipeMaterials>[]) {
    if (!key) return

    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    /*
      Uzupełnij wartości domyślne dla `optimisticParams`. Wcześniej generator
      wpisywał tu `` (pusty string) dla KAŻDEGO pola, co dla pól liczbowych
      oznaczało `mapId: ""` — bezsensowną daną, która kompilowała się tylko
      dlatego, że `Partial<T>` maskuje typ. Uzupełniaj ręcznie albo zostaw `{}`,
      jeśli nie potrzebujesz defaults.
    */
    const defaultValues = {
      id: ``,
      recipeId: ``,
      itemId: ``,
      quantity: ``,
      ownedQuantity: ``,
      missingQuantity: ``,
      canCraftMissing: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TPlayerRecipeMaterialsRecordById

    const optimisticDataMergeWithOldData: TPlayerRecipeMaterialsRecordById = {
      ...playerRecipeMaterials,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, () => fetchFresh(key), {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutatePlayerRecipeMaterials }
}
