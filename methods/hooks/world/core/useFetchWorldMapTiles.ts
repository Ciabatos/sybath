// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TWorldMapTilesRecordByXY, TWorldMapTiles } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapTilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldMapTiles() {
  const setWorldMapTiles = useSetAtom(mapTilesAtom)

  const { data } = useSWR<TWorldMapTiles[]>(`/api/world/map-tiles`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const mapTiles = arrayToObjectKey(["x", "y"], data) as TWorldMapTilesRecordByXY
      setWorldMapTiles(mapTiles)
    }
  }, [data, setWorldMapTiles])
}
