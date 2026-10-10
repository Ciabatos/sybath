// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

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
export const WORLDTERRAINTYPES_SWR_KEY_BY_KEY = (params: TWorldTerrainTypesParamsFetchParams) =>
  params.id != null ? `/api/world/terrain-types/${params.id}` : null

export function useFetchWorldTerrainTypesByKey(params: TWorldTerrainTypesParamsFetchParams) {
  const setWorldTerrainTypes = useSetAtom(terrainTypesAtom)

  const { data } = useSWR<TWorldTerrainTypes[]>(WORLDTERRAINTYPES_SWR_KEY_BY_KEY(params), {
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
