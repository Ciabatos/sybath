// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TItemsItemsRecordById,
  TItemsItemsParamsFetchParams,
  TItemsItems,
} from "@/db/postgresMainDatabase/schemas/items/items"
import { ITEMSITEMS_SWR_KEY_BY_KEY } from "@/methods/hooks/items/core/useFetchItemsItemsByKey"
import { itemsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateItemsItems(params: TItemsItemsParamsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = ITEMSITEMS_SWR_KEY_BY_KEY(params)
  const items = useAtomValue(itemsAtom)

  function mutateItemsItems(optimisticParams?: Partial<TItemsItems>[]) {
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
      name: ``,
      description: ``,
      image: ``,
      itemTypeId: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TItemsItemsRecordById

    const optimisticDataMergeWithOldData: TItemsItemsRecordById = {
      ...items,
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

  return { mutateItemsItems }
}
