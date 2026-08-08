// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TTradeInventory,
  TTradeInventoryParams,
  TTradeInventoryRecordBySlotId,
} from "@/db/postgresMainDatabase/schemas/trade/tradeInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { tradeInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchTradeInventory(params: TTradeInventoryParams) {
  const setTradeInventory = useSetAtom(tradeInventoryAtom)

  const { data } = useSWR<TTradeInventory[]>(
    `/api/trade/rpc/get-trade-inventory/${params.playerId}/${params.tradeId}`,
    { refreshInterval: 3000 },
  )

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
