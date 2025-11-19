// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"
import { terrainTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchTerrainTypes() {
  const terrainTypes = useAtomValue(terrainTypesAtom)
  const setTerrainTypes = useSetAtom(terrainTypesAtom)

  const { data } = useSWR(`/api/map/terrain-types`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeyId("id", data) as TMapTerrainTypesRecordById) : {}
      setTerrainTypes(index)
      prevDataRef.current = data
    }
  }, [data, setTerrainTypes])

  return { terrainTypes }
}
