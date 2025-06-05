"use client"
import { TCitiesByMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/cities"
import { arrayToObjectKeysId } from "@/methods/functions/converters"
import { citiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchCities() {
  const setCitiesAtom = useSetAtom(citiesAtom)
  const { data } = useSWR("/api/cities", { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const cititesByCoordinates = data ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", data) as TCitiesByMapCoordinates) : {}
      setCitiesAtom(cititesByCoordinates)
      prevDataRef.current = data
    }
  }, [data])
}
