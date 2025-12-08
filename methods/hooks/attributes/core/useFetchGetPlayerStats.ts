// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TGetPlayerStatsRecordByStatId, TGetPlayerStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerStats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerStatsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchGetPlayerStats(params: TGetPlayerStatsParams) {
  const getPlayerStats = useAtomValue(getPlayerStatsAtom)
  const setGetPlayerStats = useSetAtom(getPlayerStatsAtom)

  const { data } = useSWR(`/api/attributes/rpc/get-player-stats/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["statId"], data) as TGetPlayerStatsRecordByStatId) : {}
      setGetPlayerStats(index)
      prevDataRef.current = data
    }
  }, [data, setGetPlayerStats])

  return { getPlayerStats }
}
