// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TWorldTerrainTypesRecordById, TWorldTerrainTypes, TWorldTerrainTypesParams } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { terrainTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldTerrainTypesByKey( params: TWorldTerrainTypesParams ) {
  const terrainTypes = useAtomValue(terrainTypesAtom)
  const setWorldTerrainTypes = useSetAtom(terrainTypesAtom)
  
  const { data } = useSWR<TWorldTerrainTypes[]>(`/api/world/terrain-types/${params.id}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["id"], data) as TWorldTerrainTypesRecordById)
      setWorldTerrainTypes(index)
    }
  }, [data, setWorldTerrainTypes])

  return { terrainTypes }
}
