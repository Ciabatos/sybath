// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TPlayerInventoryRecordBySlotId , TPlayerInventoryParams, TPlayerInventory  } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { playerInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerInventory( params: TPlayerInventoryParams) {
  const { mutate } = useSWR<TPlayerInventory[]>(`api/inventory/rpc/get-player-inventory/${params.playerId}`)
  const setPlayerInventory = useSetAtom(playerInventoryAtom)
  

  function mutatePlayerInventory(optimisticParams?: Partial<TPlayerInventory> | Partial<TPlayerInventory>[]) {
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

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TPlayerInventoryRecordBySlotId
    
    const optimisticDataMergeWithOldData: TPlayerInventoryRecordBySlotId = {
       
      ...newObj,      
    }
    
    setPlayerInventory(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerInventory }
}
