// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TCitiesCitiesRecordByMapTileXMapTileY,
  TCitiesCities,
  TCitiesCitiesParams,
} from "@/db/postgresMainDatabase/schemas/cities/cities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { citiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchCitiesCitiesByKey(params: TCitiesCitiesParams) {
  const setCitiesCities = useSetAtom(citiesAtom)

  const { data } = useSWR<TCitiesCities[]>(`/api/cities/cities/${params.mapId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const cities = arrayToObjectKey(["mapTileX", "mapTileY"], data) as TCitiesCitiesRecordByMapTileXMapTileY
      setCitiesCities(cities)
    }
  }, [data, setCitiesCities])
}
