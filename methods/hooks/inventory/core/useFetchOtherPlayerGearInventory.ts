// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerGearInventoryRecordBySlotId,
  TOtherPlayerGearInventory,
  TOtherPlayerGearInventoryFetchParams,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerGearInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateOtherPlayerGearInventory` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const OTHERPLAYERGEARINVENTORY_SWR_KEY = (params: TOtherPlayerGearInventoryFetchParams) =>
  params.playerId != null && params.otherPlayerId != null
    ? `/api/inventory/rpc/get-other-player-gear-inventory/${params.playerId}/${params.otherPlayerId}`
    : null

export function useFetchOtherPlayerGearInventory(params: TOtherPlayerGearInventoryFetchParams) {
  const setOtherPlayerGearInventory = useSetAtom(otherPlayerGearInventoryAtom)

  const { data } = useSWR<TOtherPlayerGearInventory[]>(OTHERPLAYERGEARINVENTORY_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const otherPlayerGearInventory = arrayToObjectKey(["slotId"], data) as TOtherPlayerGearInventoryRecordBySlotId
      setOtherPlayerGearInventory(otherPlayerGearInventory)
    }
  }, [data, setOtherPlayerGearInventory])
}

export function useOtherPlayerGearInventoryState() {
  return useAtomValue(otherPlayerGearInventoryAtom)
}
