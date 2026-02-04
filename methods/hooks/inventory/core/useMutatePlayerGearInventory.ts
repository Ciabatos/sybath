// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TPlayerGearInventoryRecordBySlotId,  TPlayerGearInventoryParams, TPlayerGearInventory  } from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import { playerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters" 

export function useMutatePlayerGearInventory( params: TPlayerGearInventoryParams) {
  const { mutate } = useSWR<TPlayerGearInventory[]>(`/api/inventory/rpc/get-player-gear-inventory/${params.playerId}`)
  const playerGearInventory = useAtomValue(playerGearInventoryAtom)

  function mutatePlayerGearInventory(optimisticParams?: Partial<TPlayerGearInventory> | Partial<TPlayerGearInventory>[]) {
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

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TPlayerGearInventoryRecordBySlotId
    
    const optimisticDataMergeWithOldData: TPlayerGearInventoryRecordBySlotId = {
      ...playerGearInventory, 
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

  return { mutatePlayerGearInventory }
}
