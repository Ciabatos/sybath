// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TDistrictInventoryRecordBySlotId , TDistrictInventoryParams, TDistrictInventory  } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import { districtInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateDistrictInventory( params: TDistrictInventoryParams) {
  const { mutate } = useSWR<TDistrictInventory[]>(`/api/inventory/rpc/get-district-inventory/${params.districtId}`)
  const setDistrictInventory = useSetAtom(districtInventoryAtom)
  

  function mutateDistrictInventory(optimisticParams?: Partial<TDistrictInventory> | Partial<TDistrictInventory>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

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

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TDistrictInventoryRecordBySlotId
    
    const optimisticDataMergeWithOldData: TDistrictInventoryRecordBySlotId = {
       
      ...newObj,      
    }
    
    setDistrictInventory(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateDistrictInventory }
}
