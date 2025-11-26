// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { landscapeTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchWorldLandscapeTypes() {
  const landscapeTypes = useAtomValue(landscapeTypesAtom)
  const setWorldLandscapeTypes = useSetAtom(landscapeTypesAtom)
  
  const { data } = useSWR(`/api/world/landscape-types`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["id"], data) as TWorldLandscapeTypesRecordById) : {}
      setWorldLandscapeTypes(index)
      prevDataRef.current = data
    }
  }, [data, setWorldLandscapeTypes])

  return { landscapeTypes }
}
