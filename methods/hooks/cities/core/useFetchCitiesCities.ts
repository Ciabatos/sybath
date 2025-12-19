// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TCitiesCitiesRecordByMapTileXMapTileY, TCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { citiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchCitiesCities() {
  const cities = useAtomValue(citiesAtom)
  const setCitiesCities = useSetAtom(citiesAtom)
  
  const { data } = useSWR<TCitiesCities[]>(`/api/cities/cities`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["mapTileX", "mapTileY"], data) as TCitiesCitiesRecordByMapTileXMapTileY)
      setCitiesCities(index)
    }
  }, [data, setCitiesCities])

  return { cities }
}
