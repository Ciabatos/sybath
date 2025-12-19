// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TBuildingInventoryRecordBySlotId , TBuildingInventoryParams, TBuildingInventory  } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import { buildingInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateBuildingInventory( params: TBuildingInventoryParams) {
  const { mutate } = useSWR<TBuildingInventory[]>(`/api/inventory/rpc/get-building-inventory/${params.buildingId}`)
  const setBuildingInventory = useSetAtom(buildingInventoryAtom)
  

  function mutateBuildingInventory(optimisticParams: Partial<TBuildingInventory> | Partial<TBuildingInventory>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      slotId: ``,
      containerId: ``,
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
       
      ...newObj,      
    }
    
    setBuildingInventory(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateBuildingInventory }
}
