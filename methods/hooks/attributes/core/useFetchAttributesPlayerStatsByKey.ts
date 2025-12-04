// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TAttributesPlayerStatsRecordByPlayerId, TAttributesPlayerStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerStatsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchAttributesPlayerStatsByKey(params: TAttributesPlayerStatsParams) {
  const playerStats = useAtomValue(playerStatsAtom)
  const setAttributesPlayerStats = useSetAtom(playerStatsAtom)

  const { data } = useSWR(`/api/attributes/player-stats/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["playerId"], data) as TAttributesPlayerStatsRecordByPlayerId) : {}
      setAttributesPlayerStats(index)
      prevDataRef.current = data
    }
  }, [data, setAttributesPlayerStats])

  return { playerStats }
}
