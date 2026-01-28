// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { TItemsItemsRecordById, TItemsItemsParams, TItemsItems  } from "@/db/postgresMainDatabase/schemas/items/items"
import useSWR from "swr"
import { itemsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateItemsItems( params: TItemsItemsParams) {
  const { mutate } = useSWR<TItemsItems[]>(`/api/items/items/${params.id}`)
  const items = useAtomValue(itemsAtom)

  function mutateItemsItems(optimisticParams?: Partial<TItemsItems> | Partial<TItemsItems>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]
    
    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      description: ``,
      image: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TItemsItemsRecordById
    
    const optimisticDataMergeWithOldData: TItemsItemsRecordById = {
      ...items,
      ...newObj,      
    }
    
    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(optimisticDataMergeWithOldDataArray, {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateItemsItems }
}
