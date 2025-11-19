// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TMapCitiesParams, TMapCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/cities"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"
import { citiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchCitiesByKey(params: TMapCitiesParams) {
  const cities = useAtomValue(citiesAtom)
  const setCities = useSetAtom(citiesAtom)

  const { data } = useSWR(`/api/map/cities/${params.id}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeysId("mapTileX", "mapTileY", data) as TMapCitiesRecordByMapTileXMapTileY) : {}
      setCities(index)
      prevDataRef.current = data
    }
  }, [data, setCities])

  return { cities }
}
