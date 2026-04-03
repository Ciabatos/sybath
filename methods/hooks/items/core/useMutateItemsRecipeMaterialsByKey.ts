// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TItemsRecipeMaterialsRecordById,
  TItemsRecipeMaterialsParams,
  TItemsRecipeMaterials,
} from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import { recipeMaterialsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateItemsRecipeMaterials(params: TItemsRecipeMaterialsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/items/recipe-materials/${params.recipeId}`
  const recipeMaterials = useAtomValue(recipeMaterialsAtom)

  function mutateItemsRecipeMaterials(optimisticParams?: Partial<TItemsRecipeMaterials>[]) {
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
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TItemsRecipeMaterialsRecordById

    const optimisticDataMergeWithOldData: TItemsRecipeMaterialsRecordById = {
      ...recipeMaterials,
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

  return { mutateItemsRecipeMaterials }
}
