// GENERATED CODE - DO NOT EDIT MANUALLY - hookMutateMethodFetcher.hbs
"use client"

import {
  TPlayerInventoryRecordBySlotId,
  TPlayerInventoryParams,
  TPlayerInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { playerInventoryAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerInventory(params: TPlayerInventoryParams) {
  const { mutate } = useSWR(`/api/inventory/rpc/get-player-inventory/${params.playerId}`)
  const setPlayerInventory = useSetAtom(playerInventoryAtom)
  const playerInventory = useAtomValue(playerInventoryAtom)

  function mutatePlayerInventory(optimisticParams: Partial<TPlayerInventory> | Partial<TPlayerInventory>[]) {
    const params = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    const defaultValues = {
      slotId: ``,
      containerId: ``,
      itemId: ``,
      name: ``,
      quantity: ``,
    }

    const dataWithDefaults = Object.values(params).map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TPlayerInventoryRecordBySlotId

    const optimisticData: TPlayerInventoryRecordBySlotId = {
      ...playerInventory,
      ...newObj,
    }

    setPlayerInventory(optimisticData)

    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerInventory }
}
