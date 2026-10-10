// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownPlayersPositionsRecordByXY,
  TKnownPlayersPositions,
  TKnownPlayersPositionsFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownPlayersPositionsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateKnownPlayersPositions` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const KNOWNPLAYERSPOSITIONS_SWR_KEY = (params: TKnownPlayersPositionsFetchParams) =>
  params.mapId != null && params.playerId != null
    ? `/api/world/rpc/get-known-players-positions/${params.mapId}/${params.playerId}`
    : null

export function useFetchKnownPlayersPositions(params: TKnownPlayersPositionsFetchParams) {
  const setKnownPlayersPositions = useSetAtom(knownPlayersPositionsAtom)

  const { data } = useSWR<TKnownPlayersPositions[]>(KNOWNPLAYERSPOSITIONS_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const knownPlayersPositions = arrayToObjectKey(["x", "y"], data) as TKnownPlayersPositionsRecordByXY
      setKnownPlayersPositions(knownPlayersPositions)
    }
  }, [data, setKnownPlayersPositions])
}

export function useKnownPlayersPositionsState() {
  return useAtomValue(knownPlayersPositionsAtom)
}
