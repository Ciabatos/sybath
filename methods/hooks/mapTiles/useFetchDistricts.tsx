"use client"
import { TDistrictsByMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/districts"
import { arrayToObjectKeysId } from "@/methods/functions/converters"
import { districtsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchDistricts() {
  const setDistrictsAtom = useSetAtom(districtsAtom)
  const { data } = useSWR("/api/districts", { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const districtByCoordinates = data ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", data) as TDistrictsByMapCoordinates) : {}
      setDistrictsAtom(districtByCoordinates)
      prevDataRef.current = data
    }
  }, [data])
}
