// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerStatsRecordByStatId, TPlayerStats , TPlayerStatsParams  } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerStatsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerStats( params: TPlayerStatsParams) {
  const playerStats = useAtomValue(playerStatsAtom)
  const setPlayerStats = useSetAtom(playerStatsAtom)

  const { data } = useSWR<TPlayerStats[]>(`/api/attributes/rpc/get-player-stats/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["statId"], data) as TPlayerStatsRecordByStatId)
      setPlayerStats(index)
    }
  }, [data, setPlayerStats])
  
  return { playerStats }
}
