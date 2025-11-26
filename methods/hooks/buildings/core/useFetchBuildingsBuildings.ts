// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TBuildingsBuildingsRecordByCityIdCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchBuildingsBuildings() {
  const buildings = useAtomValue(buildingsAtom)
  const setBuildingsBuildings = useSetAtom(buildingsAtom)
  
  const { data } = useSWR(`/api/buildings/buildings`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["cityId", "cityTileX", "cityTileY"], data) as TBuildingsBuildingsRecordByCityIdCityTileXCityTileY) : {}
      setBuildingsBuildings(index)
      prevDataRef.current = data
    }
  }, [data, setBuildingsBuildings])

  return { buildings }
}
