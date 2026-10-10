// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerRecipesRecordByItemId,
  TPlayerRecipesFetchParams,
  TPlayerRecipes,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipes"
import { PLAYERRECIPES_SWR_KEY } from "@/methods/hooks/items/core/useFetchPlayerRecipes"
import { playerRecipesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerRecipes(params: TPlayerRecipesFetchParams) {
  const { mutate } = useSWRConfig()
  const key = PLAYERRECIPES_SWR_KEY(params)
  const playerRecipes = useAtomValue(playerRecipesAtom)

  function mutatePlayerRecipes(optimisticParams?: Partial<TPlayerRecipes>[]) {
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
      itemId: ``,
      description: ``,
      image: ``,
      skillId: ``,
      value: ``,
      canCraft: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["itemId"], dataWithDefaults) as TPlayerRecipesRecordByItemId

    const optimisticDataMergeWithOldData: TPlayerRecipesRecordByItemId = {
      ...playerRecipes,
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

  return { mutatePlayerRecipes }
}
