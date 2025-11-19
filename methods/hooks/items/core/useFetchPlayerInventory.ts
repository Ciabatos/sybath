// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerInventoryParams, TPlayerInventoryRecordByRowCol } from "@/db/postgresMainDatabase/schemas/items/playerInventory"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"
import { playerInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerInventory(params: TPlayerInventoryParams) {
  const playerInventory = useAtomValue(playerInventoryAtom)
  const setPlayerInventory = useSetAtom(playerInventoryAtom)

  const { data } = useSWR(`/api/items/rpc/player-inventory/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeysId("row", "col", data) as TPlayerInventoryRecordByRowCol) : {}
      setPlayerInventory(index)
      prevDataRef.current = data
    }
  }, [data, setPlayerInventory])

  return { playerInventory }
}
