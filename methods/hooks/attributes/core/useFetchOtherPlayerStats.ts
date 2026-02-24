// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerStatsRecordByStatId,
  TOtherPlayerStats,
  TOtherPlayerStatsParams,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerStats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerStatsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchOtherPlayerStats(params: TOtherPlayerStatsParams) {
  const setOtherPlayerStats = useSetAtom(otherPlayerStatsAtom)

  const { data } = useSWR<TOtherPlayerStats[]>(
    `/api/attributes/rpc/get-other-player-stats/${params.playerId}/${params.otherPlayerId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const otherPlayerStats = arrayToObjectKey(["statId"], data) as TOtherPlayerStatsRecordByStatId
      setOtherPlayerStats(otherPlayerStats)
    }
  }, [data, setOtherPlayerStats])
}
