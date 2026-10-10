// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerGearInventoryRecordBySlotId,
  TPlayerGearInventory,
  TPlayerGearInventoryFetchParams,
} from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerGearInventory` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERGEARINVENTORY_SWR_KEY = (params: TPlayerGearInventoryFetchParams) =>
  params.playerId != null ? `/api/inventory/rpc/get-player-gear-inventory/${params.playerId}` : null

export function useFetchPlayerGearInventory(params: TPlayerGearInventoryFetchParams) {
  const setPlayerGearInventory = useSetAtom(playerGearInventoryAtom)

  const { data } = useSWR<TPlayerGearInventory[]>(PLAYERGEARINVENTORY_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerGearInventory = arrayToObjectKey(["slotId"], data) as TPlayerGearInventoryRecordBySlotId
      setPlayerGearInventory(playerGearInventory)
    }
  }, [data, setPlayerGearInventory])
}

export function usePlayerGearInventoryState() {
  return useAtomValue(playerGearInventoryAtom)
}
