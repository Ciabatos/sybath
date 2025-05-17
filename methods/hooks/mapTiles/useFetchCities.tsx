"use client"
import { TCitiesByMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/cities"
import { arrayToObjectKeysId } from "@/methods/functions/converters"
import { citiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchCities() {
  const setCitiesAtom = useSetAtom(citiesAtom)
  const { data, error, isLoading } = useSWR("/api/cities", { refreshInterval: 1 })

  useEffect(() => {
    const cititesByCoordinates = data ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", data) as TCitiesByMapCoordinates) : {}
    setCitiesAtom(cititesByCoordinates)
  }, [data, error, isLoading, setCitiesAtom])
}
