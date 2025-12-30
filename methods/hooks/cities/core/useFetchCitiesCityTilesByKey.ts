// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TCitiesCityTilesRecordByXY,
  TCitiesCityTiles,
  TCitiesCityTilesParams,
} from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { cityTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchCitiesCityTilesByKey(params: TCitiesCityTilesParams) {
  const cityTiles = useAtomValue(cityTilesAtom)
  const setCitiesCityTiles = useSetAtom(cityTilesAtom)

  const { data } = useSWR<TCitiesCityTiles[]>(`/api/cities/city-tiles/${params.cityId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = arrayToObjectKey(["x", "y"], data) as TCitiesCityTilesRecordByXY
      setCitiesCityTiles(index)
    }
  }, [data, setCitiesCityTiles])

  return { cityTiles }
}
