// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TWorldMapsRecordById, TWorldMapsParams } from "@/db/postgresMainDatabase/schemas/world/maps"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchWorldMapsByKey(params: TWorldMapsParams) {
  const maps = useAtomValue(mapsAtom)
  const setWorldMaps = useSetAtom(mapsAtom)

  const { data } = useSWR(`/api/world/maps/${params.id}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["id"], data) as TWorldMapsRecordById) : {}
      setWorldMaps(index)
      prevDataRef.current = data
    }
  }, [data, setWorldMaps])

  return { maps }
}
