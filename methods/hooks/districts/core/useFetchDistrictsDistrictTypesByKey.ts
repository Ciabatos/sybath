// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TDistrictsDistrictTypesRecordById, TDistrictsDistrictTypesParams } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistrictTypesByKey(params: TDistrictsDistrictTypesParams) {
  const districtTypes = useAtomValue(districtTypesAtom)
  const setDistrictsDistrictTypes = useSetAtom(districtTypesAtom)

  const { data } = useSWR(`/api/districts/district-types/${params.id}`, { refreshInterval: 3000 })

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
