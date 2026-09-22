// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TTradeInventoryRecordBySlotId,
  TTradeInventoryParams,
  TTradeInventory,
} from "@/db/postgresMainDatabase/schemas/trade/tradeInventory"
import { tradeInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateTradeInventory(params: TTradeInventoryParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/trade/rpc/get-trade-inventory/${params.playerId}/${params.tradeId}`
  const tradeInventory = useAtomValue(tradeInventoryAtom)

  function mutateTradeInventory(optimisticParams?: Partial<TTradeInventory>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      slotId: ``,
      containerId: ``,
      inventoryContainerTypeId: ``,
      inventorySlotTypeId: ``,
      itemId: ``,
      name: ``,
      quantity: ``,
      side: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TTradeInventoryRecordBySlotId

    const optimisticDataMergeWithOldData: TTradeInventoryRecordBySlotId = {
      ...tradeInventory,
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

  return { mutateTradeInventory }
}
