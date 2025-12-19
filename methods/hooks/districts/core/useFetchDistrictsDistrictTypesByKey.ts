// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TDistrictsDistrictTypesRecordById, TDistrictsDistrictTypes, TDistrictsDistrictTypesParams } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistrictTypesByKey( params: TDistrictsDistrictTypesParams ) {
  const districtTypes = useAtomValue(districtTypesAtom)
  const setDistrictsDistrictTypes = useSetAtom(districtTypesAtom)
  
  const { data } = useSWR<TDistrictsDistrictTypes[]>(`/api/districts/district-types/${params.id}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["id"], data) as TDistrictsDistrictTypesRecordById)
      setDistrictsDistrictTypes(index)
    }
  }, [data, setDistrictsDistrictTypes])

  return { districtTypes }
}
