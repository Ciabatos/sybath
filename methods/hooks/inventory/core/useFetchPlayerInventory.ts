// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerInventory,
  TPlayerInventoryParams,
  TPlayerInventoryRecordBySlotId,
} from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerInventory(params: TPlayerInventoryParams) {
  const setPlayerInventory = useSetAtom(playerInventoryAtom)

  const { data, isLoading } = useSWR<TPlayerInventory[]>(`/api/inventory/rpc/get-player-inventory/${params.playerId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      console.log("Fetched player inventory:", isLoading, data)
      const playerInventory = arrayToObjectKey(["slotId"], data) as TPlayerInventoryRecordBySlotId
      setPlayerInventory(playerInventory)
    }
  }, [data, setPlayerInventory])
}
