// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TWorldTerrainTypesRecordById, TWorldTerrainTypes, TWorldTerrainTypesParams } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { terrainTypesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldTerrainTypesByKey( params: TWorldTerrainTypesParams ) {
  const setWorldTerrainTypes = useSetAtom(terrainTypesAtom)
  
  const { data } = useSWR<TWorldTerrainTypes[]>(`/api/world/terrain-types/${params.id}`, { refreshInterval: 3000 })

  const terrainTypes = data
  ? (arrayToObjectKey(["id"], data) as TWorldTerrainTypesRecordById)
  : undefined

  useEffect(() => {
    if (terrainTypes) {
      setWorldTerrainTypes(terrainTypes)
    }
  }, [terrainTypes, setWorldTerrainTypes])

  return { terrainTypes }
}
