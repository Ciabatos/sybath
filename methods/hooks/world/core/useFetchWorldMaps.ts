// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TWorldMapsRecordById, TWorldMaps } from "@/db/postgresMainDatabase/schemas/world/maps"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldMaps() {
  const maps = useAtomValue(mapsAtom)
  const setWorldMaps = useSetAtom(mapsAtom)

  const { data } = useSWR<TWorldMaps[]>(`/api/world/maps`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = arrayToObjectKey(["id"], data) as TWorldMapsRecordById
      setWorldMaps(index)
    }
  }, [data, setWorldMaps])

  return { maps }
}
