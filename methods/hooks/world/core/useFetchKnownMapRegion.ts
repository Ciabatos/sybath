// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownMapRegionRecordByMapTileXMapTileY,
  TKnownMapRegion,
  TKnownMapRegionFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownMapRegionAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateKnownMapRegion` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const KNOWNMAPREGION_SWR_KEY = (params: TKnownMapRegionFetchParams) =>
  params.mapId != null && params.playerId != null && params.regionType != null
    ? `/api/world/rpc/get-known-map-region/${params.mapId}/${params.playerId}/${params.regionType}`
    : null

export function useFetchKnownMapRegion(params: TKnownMapRegionFetchParams) {
  const setKnownMapRegion = useSetAtom(knownMapRegionAtom)

  const { data } = useSWR<TKnownMapRegion[]>(KNOWNMAPREGION_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const knownMapRegion = arrayToObjectKey(["mapTileX", "mapTileY"], data) as TKnownMapRegionRecordByMapTileXMapTileY
      setKnownMapRegion(knownMapRegion)
    }
  }, [data, setKnownMapRegion])
}

export function useKnownMapRegionState() {
  return useAtomValue(knownMapRegionAtom)
}
