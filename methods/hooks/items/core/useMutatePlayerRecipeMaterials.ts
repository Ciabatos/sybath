// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerRecipeMaterialsRecordById,
  TPlayerRecipeMaterialsParams,
  TPlayerRecipeMaterials,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipeMaterials"
import { playerRecipeMaterialsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerRecipeMaterials(params: TPlayerRecipeMaterialsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/items/rpc/get-player-recipe-materials/${params.playerId}/${params.recipeId}`
  const playerRecipeMaterials = useAtomValue(playerRecipeMaterialsAtom)

  function mutatePlayerRecipeMaterials(optimisticParams?: Partial<TPlayerRecipeMaterials>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      recipeId: ``,
      itemId: ``,
      quantity: ``,
      ownedQuantity: ``,
      missingQuantity: ``,
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
