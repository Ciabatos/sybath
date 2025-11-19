// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TMapCityTilesRecordByXY, TMapCityTilesParams } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import { arrayToObjectKeysId } from "@/methods/functions/converters"
import { cityTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchCityTilesByKey( params: TMapCityTilesParams ) {
  const cityTiles = useAtomValue(cityTilesAtom)
  const setCityTiles = useSetAtom(cityTilesAtom)
  
  const { data } = useSWR(`/api/map/city-tiles/${params.x}/${params.y}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeysId("x", "y", data) as TMapCityTilesRecordByXY) : {}
      setCityTiles(index)
      prevDataRef.current = data
    }
  }, [data, setCityTiles])

  return { cityTiles }
}
