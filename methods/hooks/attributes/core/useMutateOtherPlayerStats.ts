// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TOtherPlayerStatsRecordByStatId,
  TOtherPlayerStatsParams,
  TOtherPlayerStats,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerStats"
import { otherPlayerStatsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerStats(params: TOtherPlayerStatsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/rpc/get-other-player-stats/${params.playerId}/${params.otherPlayerMaskId}`
  const otherPlayerStats = useAtomValue(otherPlayerStatsAtom)

  function mutateOtherPlayerStats(optimisticParams?: Partial<TOtherPlayerStats>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      statId: ``,
      value: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["statId"], dataWithDefaults) as TOtherPlayerStatsRecordByStatId

    const optimisticDataMergeWithOldData: TOtherPlayerStatsRecordByStatId = {
      ...otherPlayerStats,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, optimisticDataMergeWithOldDataArray, {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateOtherPlayerStats }
}
