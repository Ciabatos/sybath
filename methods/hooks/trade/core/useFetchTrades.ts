// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TTradesRecordById, TTrades, TTradesParams } from "@/db/postgresMainDatabase/schemas/trade/trades"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { tradesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchTrades(params: TTradesParams) {
  const setTrades = useSetAtom(tradesAtom)

  const { data } = useSWR<TTrades[]>(`/api/trade/rpc/get-trades/${params.playerId}`, { refreshInterval: 3000 })

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
