// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TBuildingsBuildingTypesRecordById, TBuildingsBuildingTypes, TBuildingsBuildingTypesParams } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingTypesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchBuildingsBuildingTypesByKey( params: TBuildingsBuildingTypesParams ) {
  const setBuildingsBuildingTypes = useSetAtom(buildingTypesAtom)
  
  const { data } = useSWR<TBuildingsBuildingTypes[]>(`/api/buildings/building-types/${params.id}`, { refreshInterval: 3000 })

  const buildingTypes = data
  ? (arrayToObjectKey(["id"], data) as TBuildingsBuildingTypesRecordById)
  : undefined

  useEffect(() => {
    if (buildingTypes) {
      setBuildingsBuildingTypes(buildingTypes)
    }
  }, [buildingTypes, setBuildingsBuildingTypes])

  return { buildingTypes }
}
