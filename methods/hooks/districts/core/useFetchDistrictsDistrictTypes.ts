// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

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
export const DISTRICTSDISTRICTTYPES_SWR_KEY = () => `/api/districts/district-types`

export function useFetchDistrictsDistrictTypes() {
  const setDistrictsDistrictTypes = useSetAtom(districtTypesAtom)

  const { data } = useSWR<TDistrictsDistrictTypes[]>(DISTRICTSDISTRICTTYPES_SWR_KEY(), {
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
