// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TOtherPlayerGearInventoryRecordBySlotId,
  TOtherPlayerGearInventoryParams,
  TOtherPlayerGearInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerGearInventory"
import { otherPlayerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerGearInventory(params: TOtherPlayerGearInventoryParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/inventory/rpc/get-other-player-gear-inventory/${params.playerId}/${params.otherPlayerMaskId}`
  const otherPlayerGearInventory = useAtomValue(otherPlayerGearInventoryAtom)

  function mutateOtherPlayerGearInventory(optimisticParams?: Partial<TOtherPlayerGearInventory>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

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

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TOtherPlayerGearInventoryRecordBySlotId

    const optimisticDataMergeWithOldData: TOtherPlayerGearInventoryRecordBySlotId = {
      ...otherPlayerGearInventory,
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

  return { mutateOtherPlayerGearInventory }
}
