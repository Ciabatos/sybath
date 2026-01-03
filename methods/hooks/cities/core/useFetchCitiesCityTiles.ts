// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TCitiesCityTilesRecordByXY, TCitiesCityTiles } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { cityTilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchCitiesCityTiles() {
  const setCitiesCityTiles = useSetAtom(cityTilesAtom)
  
  const { data } = useSWR<TCitiesCityTiles[]>(`/api/cities/city-tiles`, { refreshInterval: 3000 })

  const cityTiles = data
  ? (arrayToObjectKey(["x", "y"], data) as TCitiesCityTilesRecordByXY)
  : {}

  useEffect(() => {
    if (cityTiles) {
      setCitiesCityTiles(cityTiles)
    }
  }, [cityTiles, setCitiesCityTiles])

  return { cityTiles }
}
