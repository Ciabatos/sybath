// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TPlayerStatsRecordByStatId , TPlayerStatsParams, TPlayerStats  } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { playerStatsAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerStats( params: TPlayerStatsParams) {
  const { mutate } = useSWR<TPlayerStats[]>(`/api/attributes/rpc/get-player-stats/${params.playerId}`)
  const setPlayerStats = useSetAtom(playerStatsAtom)
  const playerStats = useAtomValue(playerStatsAtom)

  function mutatePlayerStats(optimisticParams: Partial<TPlayerStats> | Partial<TPlayerStats>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      statId: ``,
      value: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["statId"], dataWithDefaults) as TPlayerStatsRecordByStatId
    
    const optimisticDataMergeWithOldData: TPlayerStatsRecordByStatId = {
      ...playerStats, 
      ...newObj,      
    }
    
    setPlayerStats(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerStats }
}
