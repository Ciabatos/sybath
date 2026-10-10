// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TDistrictsDistrictTypesRecordById,
  TDistrictsDistrictTypes,
  TDistrictsDistrictTypesParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateDistrictsDistrictTypes` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const DISTRICTSDISTRICTTYPES_SWR_KEY_BY_KEY = (params: TDistrictsDistrictTypesParamsFetchParams) =>
  params.id != null ? `/api/districts/district-types/${params.id}` : null

export function useFetchDistrictsDistrictTypesByKey(params: TDistrictsDistrictTypesParamsFetchParams) {
  const setDistrictsDistrictTypes = useSetAtom(districtTypesAtom)

  const { data } = useSWR<TDistrictsDistrictTypes[]>(DISTRICTSDISTRICTTYPES_SWR_KEY_BY_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const districtTypes = arrayToObjectKey(["id"], data) as TDistrictsDistrictTypesRecordById
      setDistrictsDistrictTypes(districtTypes)
    }
  }, [data, setDistrictsDistrictTypes])
}

export function useDistrictsDistrictTypesState() {
  return useAtomValue(districtTypesAtom)
}
