// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerInventoryRecordBySlotId, TPlayerInventory , TPlayerInventoryParams  } from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerInventory( params: TPlayerInventoryParams) {
  const playerInventory = useAtomValue(playerInventoryAtom)
  const setPlayerInventory = useSetAtom(playerInventoryAtom)

  const { data } = useSWR<TPlayerInventory[]>(`api/inventory/rpc/get-player-inventory/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["slotId"], data) as TPlayerInventoryRecordBySlotId)
      setPlayerInventory(index)
    }
  }, [data, setPlayerInventory])
  
  return { playerInventory }
}
