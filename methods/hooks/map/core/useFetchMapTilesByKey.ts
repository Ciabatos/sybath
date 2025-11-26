// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TMapMapTilesParams, TMapMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchMapTilesByKey(params: TMapMapTilesParams) {
  const mapTiles = useAtomValue(mapTilesAtom)
  const setMapTiles = useSetAtom(mapTilesAtom)

  const { data } = useSWR(`/api/map/map-tiles/${params.x}/${params.y}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey("x", "y", data) as TMapMapTilesRecordByXY) : {}
      setMapTiles(index)
      prevDataRef.current = data
    }
  }, [data, setMapTiles])

  return { mapTiles }
}
