// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TCitiesCitiesRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { citiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchCitiesCities() {
  const cities = useAtomValue(citiesAtom)
  const setCitiesCities = useSetAtom(citiesAtom)
  
  const { data } = useSWR(`/api/cities/cities`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["mapId", "mapTileX", "mapTileY"], data) as TCitiesCitiesRecordByMapIdMapTileXMapTileY) : {}
      setCitiesCities(index)
      prevDataRef.current = data
    }
  }, [data, setCitiesCities])

  return { cities }
}
