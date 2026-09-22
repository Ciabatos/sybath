// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerRecipesRecordByItemId,
  TPlayerRecipesParams,
  TPlayerRecipes,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipes"
import { playerRecipesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerRecipes(params: TPlayerRecipesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/items/rpc/get-player-recipes/${params.playerId}`
  const playerRecipes = useAtomValue(playerRecipesAtom)

  function mutatePlayerRecipes(optimisticParams?: Partial<TPlayerRecipes>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

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
