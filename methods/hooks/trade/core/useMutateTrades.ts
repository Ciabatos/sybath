// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import { TTradesRecordByTradeId, TTradesParams, TTrades } from "@/db/postgresMainDatabase/schemas/trade/trades"
import { tradesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateTrades(params: TTradesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/trade/rpc/get-trades/${params.playerId}`
  const trades = useAtomValue(tradesAtom)

  function mutateTrades(optimisticParams?: Partial<TTrades>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      tradeId: ``,
      status: ``,
      createdAt: ``,
      updatedAt: ``,
      expiresAt: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["tradeId"], dataWithDefaults) as TTradesRecordByTradeId

    const optimisticDataMergeWithOldData: TTradesRecordByTradeId = {
      ...trades,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, () => fetchFresh(key), {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateTrades }
}
