// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerGearInventoryRecordBySlotId, TPlayerGearInventory , TPlayerGearInventoryParams  } from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerGearInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerGearInventory( params: TPlayerGearInventoryParams) {
  const setPlayerGearInventory = useSetAtom(playerGearInventoryAtom)

  const { data } = useSWR<TPlayerGearInventory[]>(`/api/inventory/rpc/get-player-gear-inventory/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const playerGearInventory = arrayToObjectKey(["slotId"], data) as TPlayerGearInventoryRecordBySlotId
      setPlayerGearInventory(playerGearInventory)
    }
  }, [data, setPlayerGearInventory])
}
