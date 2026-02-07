// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TPlayerStatsRecordByStatId,
  TPlayerStatsParams,
  TPlayerStats,
} from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { playerStatsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerStats(params: TPlayerStatsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/rpc/get-player-stats/${params.playerId}`
  const playerStats = useAtomValue(playerStatsAtom)

  function mutatePlayerStats(optimisticParams?: Partial<TPlayerStats>[]) {
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

    const newObj = arrayToObjectKey(["statId"], dataWithDefaults) as TPlayerStatsRecordByStatId

    const optimisticDataMergeWithOldData: TPlayerStatsRecordByStatId = {
      ...playerStats,
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

  return { mutatePlayerStats }
}
