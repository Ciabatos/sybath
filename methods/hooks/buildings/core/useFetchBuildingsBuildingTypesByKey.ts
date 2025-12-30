// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TBuildingsBuildingTypesRecordById,
  TBuildingsBuildingTypes,
  TBuildingsBuildingTypesParams,
} from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchBuildingsBuildingTypesByKey(params: TBuildingsBuildingTypesParams) {
  const buildingTypes = useAtomValue(buildingTypesAtom)
  const setBuildingsBuildingTypes = useSetAtom(buildingTypesAtom)

  const { data } = useSWR<TBuildingsBuildingTypes[]>(`/api/buildings/building-types/${params.id}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const index = arrayToObjectKey(["id"], data) as TBuildingsBuildingTypesRecordById
      setBuildingsBuildingTypes(index)
    }
  }, [data, setBuildingsBuildingTypes])

  return { buildingTypes }
}
