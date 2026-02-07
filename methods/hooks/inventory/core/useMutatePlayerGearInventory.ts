// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import {
  TPlayerGearInventory,
  TPlayerGearInventoryParams,
  TPlayerGearInventoryRecordBySlotId,
} from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { useSWRConfig } from "swr"

export function useMutatePlayerGearInventory(params: TPlayerGearInventoryParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/inventory/rpc/get-player-gear-inventory/${params.playerId}`
  const playerGearInventory = useAtomValue(playerGearInventoryAtom)

  function mutatePlayerGearInventory(optimisticParams?: Partial<TPlayerGearInventory>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      slotId: 0,
      containerId: 0,
      inventoryContainerTypeId: 0,
      inventorySlotTypeId: 0,
      itemId: 0,
      name: ``,
      quantity: 0,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TPlayerGearInventoryRecordBySlotId

    const optimisticDataMergeWithOldData: TPlayerGearInventoryRecordBySlotId = {
      ...playerGearInventory,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, optimisticDataMergeWithOldDataArray, {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutatePlayerGearInventory }
}
