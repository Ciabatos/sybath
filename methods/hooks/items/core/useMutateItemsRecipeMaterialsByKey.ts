// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TItemsRecipeMaterialsRecordById,
  TItemsRecipeMaterialsParamsFetchParams,
  TItemsRecipeMaterials,
} from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import { ITEMSRECIPEMATERIALS_SWR_KEY_BY_KEY } from "@/methods/hooks/items/core/useFetchItemsRecipeMaterialsByKey"
import { recipeMaterialsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateItemsRecipeMaterials(params: TItemsRecipeMaterialsParamsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = ITEMSRECIPEMATERIALS_SWR_KEY_BY_KEY(params)
  const recipeMaterials = useAtomValue(recipeMaterialsAtom)

  function mutateItemsRecipeMaterials(optimisticParams?: Partial<TItemsRecipeMaterials>[]) {
    if (!key) return

    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    /*
      Uzupełnij wartości domyślne dla `optimisticParams`. Wcześniej generator
      wpisywał tu `` (pusty string) dla KAŻDEGO pola, co dla pól liczbowych
      oznaczało `id: ""` — bezsensowną daną, kompilującą się tylko dlatego, że
      `Partial<T>` maskuje typ. Uzupełniaj ręcznie albo zostaw `{}`.
    */
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
