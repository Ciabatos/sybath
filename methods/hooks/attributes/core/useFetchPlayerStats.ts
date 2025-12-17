// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerStatsRecordByStatId,
  TPlayerStatsParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerStatsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerStats(params: TPlayerStatsParams) {
  const playerStats = useAtomValue(playerStatsAtom)
  const setPlayerStats = useSetAtom(playerStatsAtom)

  const { data } = useSWR(`/api/attributes/rpc/get-player-stats/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["statId"], data) as TPlayerStatsRecordByStatId) : {}
      setPlayerStats(index)
      prevDataRef.current = data
    }
  }, [data, setPlayerStats])

  return { playerStats }
}
