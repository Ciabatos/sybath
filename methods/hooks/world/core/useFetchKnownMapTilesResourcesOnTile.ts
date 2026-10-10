// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId,
  TKnownMapTilesResourcesOnTile,
  TKnownMapTilesResourcesOnTileFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnTile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownMapTilesResourcesOnTileAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateKnownMapTilesResourcesOnTile` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const KNOWNMAPTILESRESOURCESONTILE_SWR_KEY = (params: TKnownMapTilesResourcesOnTileFetchParams) =>
  params.mapId != null && params.mapTileX != null && params.mapTileY != null && params.playerId != null
    ? `/api/world/rpc/get-known-map-tiles-resources-on-tile/${params.mapId}/${params.mapTileX}/${params.mapTileY}/${params.playerId}`
    : null

export function useFetchKnownMapTilesResourcesOnTile(params: TKnownMapTilesResourcesOnTileFetchParams) {
  const setKnownMapTilesResourcesOnTile = useSetAtom(knownMapTilesResourcesOnTileAtom)

  const { data } = useSWR<TKnownMapTilesResourcesOnTile[]>(KNOWNMAPTILESRESOURCESONTILE_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const knownMapTilesResourcesOnTile = arrayToObjectKey(
        ["mapTilesResourceId"],
        data,
      ) as TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId
      setKnownMapTilesResourcesOnTile(knownMapTilesResourcesOnTile)
    }
  }, [data, setKnownMapTilesResourcesOnTile])
}

export function useKnownMapTilesResourcesOnTileState() {
  return useAtomValue(knownMapTilesResourcesOnTileAtom)
}
