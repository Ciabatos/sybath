// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerStatsRecordByStatId,
  TOtherPlayerStats,
  TOtherPlayerStatsFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerStats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerStatsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateOtherPlayerStats` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const OTHERPLAYERSTATS_SWR_KEY = (params: TOtherPlayerStatsFetchParams) =>
  params.playerId != null && params.otherPlayerId != null
    ? `/api/attributes/rpc/get-other-player-stats/${params.playerId}/${params.otherPlayerId}`
    : null

export function useFetchOtherPlayerStats(params: TOtherPlayerStatsFetchParams) {
  const setOtherPlayerStats = useSetAtom(otherPlayerStatsAtom)

  const { data } = useSWR<TOtherPlayerStats[]>(OTHERPLAYERSTATS_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const otherPlayerStats = arrayToObjectKey(["statId"], data) as TOtherPlayerStatsRecordByStatId
      setOtherPlayerStats(otherPlayerStats)
    }
  }, [data, setOtherPlayerStats])
}

export function useOtherPlayerStatsState() {
  return useAtomValue(otherPlayerStatsAtom)
}
