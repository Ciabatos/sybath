// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TCitiesCitiesRecordByMapTileXMapTileY, TCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { citiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchCitiesCities() {
  const setCitiesCities = useSetAtom(citiesAtom)
  
  const { data } = useSWR<TCitiesCities[]>(`/api/cities/cities`, { refreshInterval: 3000 })

  const cities = data
  ? (arrayToObjectKey(["mapTileX", "mapTileY"], data) as TCitiesCitiesRecordByMapTileXMapTileY)
  : undefined

  useEffect(() => {
    if (cities) {
      setCitiesCities(cities)
    }
  }, [cities, setCitiesCities])

  return { cities }
}
