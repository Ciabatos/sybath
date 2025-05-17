"use client"
import { TDistrictsByMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/districts"
import { arrayToObjectKeysId } from "@/methods/functions/converters"
import { districtsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDistricts() {
  const setDistrictsAtom = useSetAtom(districtsAtom)
  const { data, error, isLoading } = useSWR("/api/districts", { refreshInterval: 1, revalidateOnFocus: true })

  useEffect(() => {
    const districtByCoordinates = data ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", data) as TDistrictsByMapCoordinates) : {}
    setDistrictsAtom(districtByCoordinates)
    console.log("districts", districtByCoordinates)
  }, [data, error, isLoading, setDistrictsAtom])
}
