// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TBuildingsBuildingsRecordByCityTileXCityTileY, TBuildingsBuildings } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchBuildingsBuildings() {
  const setBuildingsBuildings = useSetAtom(buildingsAtom)
  
  const { data } = useSWR<TBuildingsBuildings[]>(`/api/buildings/buildings`, { refreshInterval: 3000 })

  const buildings = data
  ? (arrayToObjectKey(["cityTileX", "cityTileY"], data) as TBuildingsBuildingsRecordByCityTileXCityTileY)
  : {}

  useEffect(() => {
    if (buildings) {
      setBuildingsBuildings(buildings)
    }
  }, [buildings, setBuildingsBuildings])

  return { buildings }
}
