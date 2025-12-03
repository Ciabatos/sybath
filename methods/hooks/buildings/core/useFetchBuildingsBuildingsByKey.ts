// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TBuildingsBuildingsRecordByCityTileXCityTileY, TBuildingsBuildingsParams } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchBuildingsBuildingsByKey( params: TBuildingsBuildingsParams ) {
  const buildings = useAtomValue(buildingsAtom)
  const setBuildingsBuildings = useSetAtom(buildingsAtom)
  
  const { data } = useSWR(`/api/buildings/buildings/${params.cityId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["cityTileX", "cityTileY"], data) as TBuildingsBuildingsRecordByCityTileXCityTileY) : {}
      setBuildingsBuildings(index)
      prevDataRef.current = data
    }
  }, [data, setBuildingsBuildings])

  return { buildings }
}
