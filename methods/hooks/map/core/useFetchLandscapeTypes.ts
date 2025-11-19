// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"
import { landscapeTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchLandscapeTypes() {
  const landscapeTypes = useAtomValue(landscapeTypesAtom)
  const setLandscapeTypes = useSetAtom(landscapeTypesAtom)

  const { data } = useSWR(`/api/map/landscape-types`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeyId("id", data) as TMapLandscapeTypesRecordById) : {}
      setLandscapeTypes(index)
      prevDataRef.current = data
    }
  }, [data, setLandscapeTypes])

  return { landscapeTypes }
}
