// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TWorldMapsRecordById, TWorldMaps, TWorldMapsParams } from "@/db/postgresMainDatabase/schemas/world/maps"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldMapsByKey( params: TWorldMapsParams ) {
  const setWorldMaps = useSetAtom(mapsAtom)
  
  const { data } = useSWR<TWorldMaps[]>(`/api/world/maps/${params.id}`, { refreshInterval: 3000 })

  const maps = data
  ? (arrayToObjectKey(["id"], data) as TWorldMapsRecordById)
  : {}

  useEffect(() => {
    if (maps) {
      setWorldMaps(maps)
    }
  }, [maps, setWorldMaps])

  return { maps }
}
