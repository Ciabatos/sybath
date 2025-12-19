// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TDistrictsDistrictTypesRecordById, TDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistrictTypes() {
  const districtTypes = useAtomValue(districtTypesAtom)
  const setDistrictsDistrictTypes = useSetAtom(districtTypesAtom)
  
  const { data } = useSWR<TDistrictsDistrictTypes[]>(`/api/districts/district-types`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["id"], data) as TDistrictsDistrictTypesRecordById)
      setDistrictsDistrictTypes(index)
    }
  }, [data, setDistrictsDistrictTypes])

  return { districtTypes }
}
