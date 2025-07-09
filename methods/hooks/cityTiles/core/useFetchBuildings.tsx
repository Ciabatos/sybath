"use client"
import { TCityBuildingsByCoordinates } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { arrayToObjectKeysId } from "@/methods/functions/converters"
import { buildingsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchBuildings(cityId: number) {
  const buildings = useAtomValue(buildingsAtom)
  const setBuildingsAtom = useSetAtom(buildingsAtom)
  const { data } = useSWR(`/api/cities/${cityId}/buildings`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const buildingsByCoordinates = data ? (arrayToObjectKeysId("city_tile_x", "city_tile_y", data) as TCityBuildingsByCoordinates) : {}

      setBuildingsAtom(buildingsByCoordinates)
      prevDataRef.current = data
    }
  }, [data])

  return { buildings }
}
