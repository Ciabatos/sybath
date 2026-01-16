// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TBuildingsBuildingTypesRecordById, TBuildingsBuildingTypes } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingTypesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchBuildingsBuildingTypes() {
  const setBuildingsBuildingTypes = useSetAtom(buildingTypesAtom)
  
  const { data } = useSWR<TBuildingsBuildingTypes[]>(`/api/buildings/building-types`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const buildingTypes = arrayToObjectKey(["id"], data) as TBuildingsBuildingTypesRecordById
      setBuildingsBuildingTypes(buildingTypes)
    }
  }, [data, setBuildingsBuildingTypes])
}
