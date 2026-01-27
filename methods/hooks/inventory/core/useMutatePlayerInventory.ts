// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import {
  TPlayerInventory,
  TPlayerInventoryParams,
  TPlayerInventoryRecordBySlotId,
} from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"

export function useMutatePlayerInventory(params: TPlayerInventoryParams) {
  const { mutate } = useSWR<TPlayerInventory[]>(`/api/inventory/rpc/get-player-inventory/${params.playerId}`)
  const setPlayerInventory = useSetAtom(playerInventoryAtom)

  function mutatePlayerInventory(optimisticParams?: Partial<TPlayerInventory> | Partial<TPlayerInventory>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      slotId: 0,
      containerId: 0,
      itemId: 0,
      name: ``,
      quantity: 0,
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
