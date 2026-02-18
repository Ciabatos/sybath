// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TWorldMapTilesMapRegionsRecordByMapTileXMapTileY,
  TWorldMapTilesMapRegions,
  TWorldMapTilesMapRegionsParams,
} from "@/db/postgresMainDatabase/schemas/world/mapTilesMapRegions"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapTilesMapRegionsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldMapTilesMapRegionsByKey(params: TWorldMapTilesMapRegionsParams) {
  const setWorldMapTilesMapRegions = useSetAtom(mapTilesMapRegionsAtom)

  const { data } = useSWR<TWorldMapTilesMapRegions[]>(`/api/world/map-tiles-map-regions/${params.mapId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const mapTilesMapRegions = arrayToObjectKey(
        ["mapTileX", "mapTileY"],
        data,
      ) as TWorldMapTilesMapRegionsRecordByMapTileXMapTileY
      setWorldMapTilesMapRegions(mapTilesMapRegions)
    }
  }, [data, setWorldMapTilesMapRegions])
}
