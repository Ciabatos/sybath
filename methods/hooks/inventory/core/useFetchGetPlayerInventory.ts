// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TGetPlayerInventoryRecordBySlotId,
  TGetPlayerInventoryParams,
} from "@/db/postgresMainDatabase/schemas/inventory/getPlayerInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchGetPlayerInventory(params: TGetPlayerInventoryParams) {
  const getPlayerInventory = useAtomValue(getPlayerInventoryAtom)
  const setGetPlayerInventory = useSetAtom(getPlayerInventoryAtom)

  const { data } = useSWR(`/api/inventory/rpc/get-player-inventory/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["slotId"], data) as TGetPlayerInventoryRecordBySlotId) : {}
      setGetPlayerInventory(index)
      prevDataRef.current = data
    }
  }, [data, setGetPlayerInventory])

  return { getPlayerInventory }
}
