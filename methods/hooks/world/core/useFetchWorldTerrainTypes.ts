// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TWorldTerrainTypesRecordById,
  TWorldTerrainTypes,
  TWorldTerrainTypesParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { terrainTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateWorldTerrainTypes` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const WORLDTERRAINTYPES_SWR_KEY = () => `/api/world/terrain-types`

export function useFetchWorldTerrainTypes() {
  const setWorldTerrainTypes = useSetAtom(terrainTypesAtom)

  const { data } = useSWR<TWorldTerrainTypes[]>(WORLDTERRAINTYPES_SWR_KEY(), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const terrainTypes = arrayToObjectKey(["id"], data) as TWorldTerrainTypesRecordById
      setWorldTerrainTypes(terrainTypes)
    }
  }, [data, setWorldTerrainTypes])
}

export function useWorldTerrainTypesState() {
  return useAtomValue(terrainTypesAtom)
}
