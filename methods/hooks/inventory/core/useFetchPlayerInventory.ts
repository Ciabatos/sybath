// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerInventoryRecordBySlotId, TPlayerInventory , TPlayerInventoryParams  } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerInventory( params: TPlayerInventoryParams) {
  const setPlayerInventory = useSetAtom(playerInventoryAtom)

  const { data } = useSWR<TPlayerInventory[]>(`api/inventory/rpc/get-player-inventory/${params.playerId}`, { refreshInterval: 3000 })

  const playerInventory = data
  ? (arrayToObjectKey(["slotId"], data) as TPlayerInventoryRecordBySlotId)
  : undefined

  useEffect(() => {
    if (playerInventory) {
      setPlayerInventory(playerInventory)
    }
  }, [playerInventory, setPlayerInventory])

  return { playerInventory }
}
