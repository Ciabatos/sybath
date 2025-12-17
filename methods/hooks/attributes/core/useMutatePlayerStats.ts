// GENERATED CODE - DO NOT EDIT MANUALLY - hookMutateMethodFetcher.hbs
"use client"

import {
  TPlayerStatsRecordByStatId,
  TPlayerStatsParams,
  TPlayerStats,
} from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { playerStatsAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerStats(params: TPlayerStatsParams) {
  const { mutate } = useSWR(`/api/attributes/rpc/get-player-stats/${params.playerId}`)
  const setPlayerStats = useSetAtom(playerStatsAtom)
  const playerStats = useAtomValue(playerStatsAtom)

  function mutatePlayerStats(optimisticParams: Partial<TPlayerStats> | Partial<TPlayerStats>[]) {
    const params = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    const defaultValues = {
      statId: ``,
      value: ``,
      name: ``,
    }

    const dataWithDefaults = Object.values(params).map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["statId"], dataWithDefaults) as TPlayerStatsRecordByStatId

    const optimisticData: TPlayerStatsRecordByStatId = {
      ...playerStats,
      ...newObj,
    }

    setPlayerStats(optimisticData)

    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerStats }
}
