// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerInventoryRecordBySlotId,
  TOtherPlayerInventory,
  TOtherPlayerInventoryFetchParams,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateOtherPlayerInventory` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const OTHERPLAYERINVENTORY_SWR_KEY = (params: TOtherPlayerInventoryFetchParams) =>
  params.playerId != null && params.otherPlayerId != null
    ? `/api/inventory/rpc/get-other-player-inventory/${params.playerId}/${params.otherPlayerId}`
    : null

export function useFetchOtherPlayerInventory(params: TOtherPlayerInventoryFetchParams) {
  const setOtherPlayerInventory = useSetAtom(otherPlayerInventoryAtom)

  const { data } = useSWR<TOtherPlayerInventory[]>(OTHERPLAYERINVENTORY_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const otherPlayerInventory = arrayToObjectKey(["slotId"], data) as TOtherPlayerInventoryRecordBySlotId
      setOtherPlayerInventory(otherPlayerInventory)
    }
  }, [data, setOtherPlayerInventory])
}

export function useOtherPlayerInventoryState() {
  return useAtomValue(otherPlayerInventoryAtom)
}
