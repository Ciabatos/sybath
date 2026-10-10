// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TBuildingsBuildingTypesRecordById,
  TBuildingsBuildingTypes,
  TBuildingsBuildingTypesParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateBuildingsBuildingTypes` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const BUILDINGSBUILDINGTYPES_SWR_KEY = () => `/api/buildings/building-types`

export function useFetchBuildingsBuildingTypes() {
  const setBuildingsBuildingTypes = useSetAtom(buildingTypesAtom)

  const { data } = useSWR<TBuildingsBuildingTypes[]>(BUILDINGSBUILDINGTYPES_SWR_KEY(), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const buildingTypes = arrayToObjectKey(["id"], data) as TBuildingsBuildingTypesRecordById
      setBuildingsBuildingTypes(buildingTypes)
    }
  }, [data, setBuildingsBuildingTypes])
}

export function useBuildingsBuildingTypesState() {
  return useAtomValue(buildingTypesAtom)
}
