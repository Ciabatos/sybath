// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TItemsItemsRecordById, TItemsItems } from "@/db/postgresMainDatabase/schemas/items/items"
import { itemsAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateItemsItems() {
  const { mutate } = useSWR<TItemsItems[]>(`/api/items/items`)
  const setItemsItems = useSetAtom(itemsAtom)
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
    
    setItemsItems(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateItemsItems }
}
