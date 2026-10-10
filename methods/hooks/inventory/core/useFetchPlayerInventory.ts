// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerInventoryRecordBySlotId,
  TPlayerInventory,
  TPlayerInventoryFetchParams,
} from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerInventory` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERINVENTORY_SWR_KEY = (params: TPlayerInventoryFetchParams) =>
  params.playerId != null ? `/api/inventory/rpc/get-player-inventory/${params.playerId}` : null

export function useFetchPlayerInventory(params: TPlayerInventoryFetchParams) {
  const setPlayerInventory = useSetAtom(playerInventoryAtom)

  const { data } = useSWR<TPlayerInventory[]>(PLAYERINVENTORY_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerInventory = arrayToObjectKey(["slotId"], data) as TPlayerInventoryRecordBySlotId
      setPlayerInventory(playerInventory)
    }
  }, [data, setPlayerInventory])
}

export function usePlayerInventoryState() {
  return useAtomValue(playerInventoryAtom)
}
