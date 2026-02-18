// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TWorldMapTilesMapRegionsRecordByRegionId,
  TWorldMapTilesMapRegions,
} from "@/db/postgresMainDatabase/schemas/world/mapTilesMapRegions"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapTilesMapRegionsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldMapTilesMapRegions() {
  const setWorldMapTilesMapRegions = useSetAtom(mapTilesMapRegionsAtom)

  const { data } = useSWR<TWorldMapTilesMapRegions[]>(`/api/world/map-tiles-map-regions`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const mapTilesMapRegions = arrayToObjectKey(["regionId"], data) as TWorldMapTilesMapRegionsRecordByRegionId
      setWorldMapTilesMapRegions(mapTilesMapRegions)
    }
  }, [data, setWorldMapTilesMapRegions])
}
