// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TDistrictsDistrictTypesRecordById, TDistrictsDistrictTypes, TDistrictsDistrictTypesParams } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtTypesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistrictTypesByKey( params: TDistrictsDistrictTypesParams ) {
  const setDistrictsDistrictTypes = useSetAtom(districtTypesAtom)
  
  const { data } = useSWR<TDistrictsDistrictTypes[]>(`/api/districts/district-types/${params.id}`, { refreshInterval: 3000 })

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
