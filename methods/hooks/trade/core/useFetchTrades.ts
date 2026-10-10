// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TTradesRecordById, TTrades, TTradesFetchParams } from "@/db/postgresMainDatabase/schemas/trade/trades"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { tradesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateTrades` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const TRADES_SWR_KEY = (params: TTradesFetchParams) =>
  params.playerId != null ? `/api/trade/rpc/get-trades/${params.playerId}` : null

export function useFetchTrades(params: TTradesFetchParams) {
  const setTrades = useSetAtom(tradesAtom)

  const { data } = useSWR<TTrades[]>(TRADES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const trades = arrayToObjectKey(["id"], data) as TTradesRecordById
      setTrades(trades)
    }
  }, [data, setTrades])
}

export function useTradesState() {
  return useAtomValue(tradesAtom)
}
