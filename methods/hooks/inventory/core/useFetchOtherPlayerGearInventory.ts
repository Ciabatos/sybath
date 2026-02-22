// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerGearInventoryRecordBySlotId,
  TOtherPlayerGearInventory,
  TOtherPlayerGearInventoryParams,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerGearInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerGearInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchOtherPlayerGearInventory(params: TOtherPlayerGearInventoryParams) {
  const setOtherPlayerGearInventory = useSetAtom(otherPlayerGearInventoryAtom)

  const { data } = useSWR<TOtherPlayerGearInventory[]>(
    `/api/inventory/rpc/get-other-player-gear-inventory/${params.playerId}/${params.otherPlayerMaskId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const otherPlayerGearInventory = arrayToObjectKey(["slotId"], data) as TOtherPlayerGearInventoryRecordBySlotId
      setOtherPlayerGearInventory(otherPlayerGearInventory)
    }
  }, [data, setOtherPlayerGearInventory])
}
