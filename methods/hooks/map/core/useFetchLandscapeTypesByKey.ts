// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TMapLandscapeTypesParams, TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"
import { landscapeTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchLandscapeTypesByKey(params: TMapLandscapeTypesParams) {
  const landscapeTypes = useAtomValue(landscapeTypesAtom)
  const setLandscapeTypes = useSetAtom(landscapeTypesAtom)

  const { data } = useSWR(`/api/map/landscape-types/${params.id}`, { refreshInterval: 3000 })

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
