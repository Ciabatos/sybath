// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TTradeInventoryRecordBySlotId,
  TTradeInventory,
  TTradeInventoryFetchParams,
} from "@/db/postgresMainDatabase/schemas/trade/tradeInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { tradeInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateTradeInventory` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const TRADEINVENTORY_SWR_KEY = (params: TTradeInventoryFetchParams) =>
  params.playerId != null && params.tradeId != null
    ? `/api/trade/rpc/get-trade-inventory/${params.playerId}/${params.tradeId}`
    : null

export function useFetchTradeInventory(params: TTradeInventoryFetchParams) {
  const setTradeInventory = useSetAtom(tradeInventoryAtom)

  const { data } = useSWR<TTradeInventory[]>(TRADEINVENTORY_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const tradeInventory = arrayToObjectKey(["slotId"], data) as TTradeInventoryRecordBySlotId
      setTradeInventory(tradeInventory)
    }
  }, [data, setTradeInventory])
}

export function useTradeInventoryState() {
  return useAtomValue(tradeInventoryAtom)
}
