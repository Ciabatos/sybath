// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TBuildingInventoryRecordBySlotId,  TBuildingInventoryParams, TBuildingInventory  } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import { buildingInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters" 

export function useMutateBuildingInventory( params: TBuildingInventoryParams) {
  const { mutate } = useSWR<TBuildingInventory[]>(`/api/inventory/rpc/get-building-inventory/${params.buildingId}`)
  const buildingInventory = useAtomValue(buildingInventoryAtom)

  function mutateBuildingInventory(optimisticParams?: Partial<TBuildingInventory> | Partial<TBuildingInventory>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      slotId: ``,
      containerId: ``,
      inventoryContainerTypeId: ``,
      inventorySlotTypeId: ``,
      itemId: ``,
      name: ``,
      quantity: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TBuildingInventoryRecordBySlotId
    
    const optimisticDataMergeWithOldData: TBuildingInventoryRecordBySlotId = {
      ...buildingInventory, 
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

  return { mutateBuildingInventory }
}
