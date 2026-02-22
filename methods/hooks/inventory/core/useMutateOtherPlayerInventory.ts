// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TOtherPlayerInventoryRecordBySlotId,
  TOtherPlayerInventoryParams,
  TOtherPlayerInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerInventory"
import { otherPlayerInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerInventory(params: TOtherPlayerInventoryParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/inventory/rpc/get-other-player-inventory/${params.playerId}/${params.otherPlayerMaskId}`
  const otherPlayerInventory = useAtomValue(otherPlayerInventoryAtom)

  function mutateOtherPlayerInventory(optimisticParams?: Partial<TOtherPlayerInventory>[]) {
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

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TOtherPlayerInventoryRecordBySlotId

    const optimisticDataMergeWithOldData: TOtherPlayerInventoryRecordBySlotId = {
      ...otherPlayerInventory,
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

  return { mutateOtherPlayerInventory }
}
