// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownMapTilesRecordByXY,
  TKnownMapTiles,
  TKnownMapTilesFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownMapTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateKnownMapTiles` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const KNOWNMAPTILES_SWR_KEY = (params: TKnownMapTilesFetchParams) =>
  params.mapId != null && params.playerId != null
    ? `/api/world/rpc/get-known-map-tiles/${params.mapId}/${params.playerId}`
    : null

export function useFetchKnownMapTiles(params: TKnownMapTilesFetchParams) {
  const setKnownMapTiles = useSetAtom(knownMapTilesAtom)

  const { data } = useSWR<TKnownMapTiles[]>(KNOWNMAPTILES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const knownMapTiles = arrayToObjectKey(["x", "y"], data) as TKnownMapTilesRecordByXY
      setKnownMapTiles(knownMapTiles)
    }
  }, [data, setKnownMapTiles])
}

export function useKnownMapTilesState() {
  return useAtomValue(knownMapTilesAtom)
}
