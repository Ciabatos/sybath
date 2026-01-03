// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TDistrictsDistrictTypesRecordById, TDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtTypesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistrictTypes() {
  const setDistrictsDistrictTypes = useSetAtom(districtTypesAtom)
  
  const { data } = useSWR<TDistrictsDistrictTypes[]>(`/api/districts/district-types`, { refreshInterval: 3000 })

  const districtTypes = data
  ? (arrayToObjectKey(["id"], data) as TDistrictsDistrictTypesRecordById)
  : {}

  useEffect(() => {
    if (districtTypes) {
      setDistrictsDistrictTypes(districtTypes)
    }
  }, [districtTypes, setDistrictsDistrictTypes])

  return { districtTypes }
}
