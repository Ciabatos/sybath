// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerMapRecordByMapId,
  TPlayerMap,
  TPlayerMapFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/playerMap"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerMapAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerMap` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERMAP_SWR_KEY = (params: TPlayerMapFetchParams) =>
  params.playerId != null ? `/api/world/rpc/get-player-map/${params.playerId}` : null

export function useFetchPlayerMap(params: TPlayerMapFetchParams) {
  const setPlayerMap = useSetAtom(playerMapAtom)

  const { data } = useSWR<TPlayerMap[]>(PLAYERMAP_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerMap = arrayToObjectKey(["mapId"], data) as TPlayerMapRecordByMapId
      setPlayerMap(playerMap)
    }
  }, [data, setPlayerMap])
}

export function usePlayerMapState() {
  return useAtomValue(playerMapAtom)
}
