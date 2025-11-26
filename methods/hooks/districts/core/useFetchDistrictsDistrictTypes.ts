// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistrictTypes() {
  const districtTypes = useAtomValue(districtTypesAtom)
  const setDistrictsDistrictTypes = useSetAtom(districtTypesAtom)
  
  const { data } = useSWR(`/api/districts/district-types`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["id"], data) as TDistrictsDistrictTypesRecordById) : {}
      setDistrictsDistrictTypes(index)
      prevDataRef.current = data
    }
  }, [data, setDistrictsDistrictTypes])

  return { districtTypes }
}
