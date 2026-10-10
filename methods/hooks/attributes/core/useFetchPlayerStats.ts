// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerStatsRecordByStatId,
  TPlayerStats,
  TPlayerStatsFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerStatsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerStats` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERSTATS_SWR_KEY = (params: TPlayerStatsFetchParams) =>
  params.playerId != null ? `/api/attributes/rpc/get-player-stats/${params.playerId}` : null

export function useFetchPlayerStats(params: TPlayerStatsFetchParams) {
  const setPlayerStats = useSetAtom(playerStatsAtom)

  const { data } = useSWR<TPlayerStats[]>(PLAYERSTATS_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerStats = arrayToObjectKey(["statId"], data) as TPlayerStatsRecordByStatId
      setPlayerStats(playerStats)
    }
  }, [data, setPlayerStats])
}

export function usePlayerStatsState() {
  return useAtomValue(playerStatsAtom)
}
