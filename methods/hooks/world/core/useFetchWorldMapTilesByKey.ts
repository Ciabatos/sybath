// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TWorldMapTilesRecordByXY,
  TWorldMapTiles,
  TWorldMapTilesParams,
} from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldMapTilesByKey(params: TWorldMapTilesParams) {
  const mapTiles = useAtomValue(mapTilesAtom)
  const setWorldMapTiles = useSetAtom(mapTilesAtom)

  const { data } = useSWR<TWorldMapTiles[]>(`/api/world/map-tiles/${params.mapId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = arrayToObjectKey(["x", "y"], data) as TWorldMapTilesRecordByXY
      setWorldMapTiles(index)
    }
  }, [data, setWorldMapTiles])

  return { mapTiles }
}
