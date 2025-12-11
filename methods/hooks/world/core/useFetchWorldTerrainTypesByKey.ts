// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TWorldTerrainTypesRecordById,
  TWorldTerrainTypesParams,
} from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { terrainTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchWorldTerrainTypesByKey(params: TWorldTerrainTypesParams) {
  const terrainTypes = useAtomValue(terrainTypesAtom)
  const setWorldTerrainTypes = useSetAtom(terrainTypesAtom)

  const { data } = useSWR(`/api/world/terrain-types/${params.id}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["id"], data) as TWorldTerrainTypesRecordById) : {}
      setWorldTerrainTypes(index)
      prevDataRef.current = data
    }
  }, [data, setWorldTerrainTypes])

  return { terrainTypes }
}
