// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY,
  TKnownMapTilesResourcesOnMap,
  TKnownMapTilesResourcesOnMapParams,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownMapTilesResourcesOnMapAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchKnownMapTilesResourcesOnMap(params: TKnownMapTilesResourcesOnMapParams) {
  const setKnownMapTilesResourcesOnMap = useSetAtom(knownMapTilesResourcesOnMapAtom)

  const { data } = useSWR<TKnownMapTilesResourcesOnMap[]>(
    `/api/world/rpc/get-known-map-tiles-resources-on-map/${params.mapId}/${params.playerId}`,
    { refreshInterval: 3000 },
  )

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
