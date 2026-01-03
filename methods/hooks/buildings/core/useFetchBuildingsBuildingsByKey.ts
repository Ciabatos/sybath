// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TBuildingsBuildingsRecordByCityTileXCityTileY, TBuildingsBuildings, TBuildingsBuildingsParams } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchBuildingsBuildingsByKey( params: TBuildingsBuildingsParams ) {
  const setBuildingsBuildings = useSetAtom(buildingsAtom)
  
  const { data } = useSWR<TBuildingsBuildings[]>(`/api/buildings/buildings/${params.cityId}`, { refreshInterval: 3000 })

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
