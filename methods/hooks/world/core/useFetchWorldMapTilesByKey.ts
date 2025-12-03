// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TWorldMapTilesRecordByXY, TWorldMapTilesParams } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchWorldMapTilesByKey( params: TWorldMapTilesParams ) {
  const mapTiles = useAtomValue(mapTilesAtom)
  const setWorldMapTiles = useSetAtom(mapTilesAtom)
  
  const { data } = useSWR(`/api/world/map-tiles/${params.mapId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["x", "y"], data) as TWorldMapTilesRecordByXY) : {}
      setWorldMapTiles(index)
      prevDataRef.current = data
    }
  }, [data, setWorldMapTiles])

  return { mapTiles }
}
