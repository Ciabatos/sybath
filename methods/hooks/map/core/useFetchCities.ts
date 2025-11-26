// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TMapCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/cities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { citiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchCities() {
  const cities = useAtomValue(citiesAtom)
  const setCities = useSetAtom(citiesAtom)

  const { data } = useSWR(`/api/map/cities`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey("mapTileX", "mapTileY", data) as TMapCitiesRecordByMapTileXMapTileY) : {}
      setCities(index)
      prevDataRef.current = data
    }
  }, [data, setCities])

  return { cities }
}
