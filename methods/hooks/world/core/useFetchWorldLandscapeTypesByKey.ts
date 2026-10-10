// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TWorldLandscapeTypesRecordById,
  TWorldLandscapeTypes,
  TWorldLandscapeTypesParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { landscapeTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateWorldLandscapeTypes` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const WORLDLANDSCAPETYPES_SWR_KEY_BY_KEY = (params: TWorldLandscapeTypesParamsFetchParams) =>
  params.id != null ? `/api/world/landscape-types/${params.id}` : null

export function useFetchWorldLandscapeTypesByKey(params: TWorldLandscapeTypesParamsFetchParams) {
  const setWorldLandscapeTypes = useSetAtom(landscapeTypesAtom)

  const { data } = useSWR<TWorldLandscapeTypes[]>(WORLDLANDSCAPETYPES_SWR_KEY_BY_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const landscapeTypes = arrayToObjectKey(["id"], data) as TWorldLandscapeTypesRecordById
      setWorldLandscapeTypes(landscapeTypes)
    }
  }, [data, setWorldLandscapeTypes])
}

export function useWorldLandscapeTypesState() {
  return useAtomValue(landscapeTypesAtom)
}
