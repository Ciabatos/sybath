// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownMapTilesResourcesOnTile,
  TKnownMapTilesResourcesOnTileParams,
  TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnTile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownMapTilesResourcesOnTileAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchKnownMapTilesResourcesOnTile(params: TKnownMapTilesResourcesOnTileParams) {
  const setKnownMapTilesResourcesOnTile = useSetAtom(knownMapTilesResourcesOnTileAtom)

  const { data } = useSWR<TKnownMapTilesResourcesOnTile[]>(
    `/api/world/rpc/get-known-map-tiles-resources-on-tile/${params.mapId}/${params.mapTileX}/${params.mapTileY}/${params.playerId}`,
    { refreshInterval: 3000 },
  )

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
