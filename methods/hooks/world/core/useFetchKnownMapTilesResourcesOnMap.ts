// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY,
  TKnownMapTilesResourcesOnMap,
  TKnownMapTilesResourcesOnMapFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownMapTilesResourcesOnMapAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateKnownMapTilesResourcesOnMap` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const KNOWNMAPTILESRESOURCESONMAP_SWR_KEY = (params: TKnownMapTilesResourcesOnMapFetchParams) =>
  params.mapId != null && params.playerId != null
    ? `/api/world/rpc/get-known-map-tiles-resources-on-map/${params.mapId}/${params.playerId}`
    : null

export function useFetchKnownMapTilesResourcesOnMap(params: TKnownMapTilesResourcesOnMapFetchParams) {
  const setKnownMapTilesResourcesOnMap = useSetAtom(knownMapTilesResourcesOnMapAtom)

  const { data } = useSWR<TKnownMapTilesResourcesOnMap[]>(KNOWNMAPTILESRESOURCESONMAP_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const knownMapTilesResourcesOnMap = arrayToObjectKey(
        ["mapTileX", "mapTileY"],
        data,
      ) as TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY
      setKnownMapTilesResourcesOnMap(knownMapTilesResourcesOnMap)
    }
  }, [data, setKnownMapTilesResourcesOnMap])
}

export function useKnownMapTilesResourcesOnMapState() {
  return useAtomValue(knownMapTilesResourcesOnMapAtom)
}
