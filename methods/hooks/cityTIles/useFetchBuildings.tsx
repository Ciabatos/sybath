"use client"
import { TCityBuildingsMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/buildings"
import { arrayToObjectKeysId } from "@/methods/functions/converters"
import { buildingsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchBuildings(cityId: number) {
  const setBuildingsAtom = useSetAtom(buildingsAtom)
  const { data } = useSWR(`/api/cities/${cityId}/buildings`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const buildingsByCoordinates = data ? (arrayToObjectKeysId("city_tile_x", "city_tile_y", data) as TCityBuildingsMapCoordinates) : {}

      setBuildingsAtom(buildingsByCoordinates)
      prevDataRef.current = data
    }
  }, [data])
}
