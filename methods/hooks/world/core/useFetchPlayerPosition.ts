// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerPositionRecordByXY,
  TPlayerPosition,
  TPlayerPositionFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerPositionAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerPosition` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERPOSITION_SWR_KEY = (params: TPlayerPositionFetchParams) =>
  params.mapId != null && params.playerId != null
    ? `/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`
    : null

export function useFetchPlayerPosition(params: TPlayerPositionFetchParams) {
  const setPlayerPosition = useSetAtom(playerPositionAtom)

  const { data } = useSWR<TPlayerPosition[]>(PLAYERPOSITION_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerPosition = arrayToObjectKey(["x", "y"], data) as TPlayerPositionRecordByXY
      setPlayerPosition(playerPosition)
    }
  }, [data, setPlayerPosition])
}

export function usePlayerPositionState() {
  return useAtomValue(playerPositionAtom)
}
