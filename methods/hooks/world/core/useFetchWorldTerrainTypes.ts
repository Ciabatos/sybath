// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TWorldTerrainTypesRecordById, TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { terrainTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldTerrainTypes() {
  const terrainTypes = useAtomValue(terrainTypesAtom)
  const setWorldTerrainTypes = useSetAtom(terrainTypesAtom)
  
  const { data } = useSWR<TWorldTerrainTypes[]>(`/api/world/terrain-types`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["id"], data) as TWorldTerrainTypesRecordById)
      setWorldTerrainTypes(index)
    }
  }, [data, setWorldTerrainTypes])

  return { terrainTypes }
}
