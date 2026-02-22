// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerInventoryRecordBySlotId,
  TOtherPlayerInventory,
  TOtherPlayerInventoryParams,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchOtherPlayerInventory(params: TOtherPlayerInventoryParams) {
  const setOtherPlayerInventory = useSetAtom(otherPlayerInventoryAtom)

  const { data } = useSWR<TOtherPlayerInventory[]>(
    `/api/inventory/rpc/get-other-player-inventory/${params.playerId}/${params.otherPlayerMaskId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const otherPlayerInventory = arrayToObjectKey(["slotId"], data) as TOtherPlayerInventoryRecordBySlotId
      setOtherPlayerInventory(otherPlayerInventory)
    }
  }, [data, setOtherPlayerInventory])
}
