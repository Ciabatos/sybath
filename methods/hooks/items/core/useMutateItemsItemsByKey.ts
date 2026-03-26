// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import { TItemsItemsRecordById, TItemsItemsParams, TItemsItems } from "@/db/postgresMainDatabase/schemas/items/items"
import { itemsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateItemsItems(params: TItemsItemsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/items/items/${params.id}`
  const items = useAtomValue(itemsAtom)

  function mutateItemsItems(optimisticParams?: Partial<TItemsItems>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      description: ``,
      image: ``,
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
