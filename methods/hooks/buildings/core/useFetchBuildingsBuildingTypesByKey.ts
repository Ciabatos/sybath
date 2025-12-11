// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TBuildingsBuildingTypesRecordById,
  TBuildingsBuildingTypesParams,
} from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchBuildingsBuildingTypesByKey(params: TBuildingsBuildingTypesParams) {
  const buildingTypes = useAtomValue(buildingTypesAtom)
  const setBuildingsBuildingTypes = useSetAtom(buildingTypesAtom)

  const { data } = useSWR(`/api/buildings/building-types/${params.id}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["id"], data) as TBuildingsBuildingTypesRecordById) : {}
      setBuildingsBuildingTypes(index)
      prevDataRef.current = data
    }
  }, [data, setBuildingsBuildingTypes])

  return { buildingTypes }
}
