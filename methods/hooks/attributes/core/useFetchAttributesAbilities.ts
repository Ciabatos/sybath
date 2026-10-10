// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TAttributesAbilitiesRecordById,
  TAttributesAbilities,
  TAttributesAbilitiesParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { abilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateAttributesAbilities` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ATTRIBUTESABILITIES_SWR_KEY = () => `/api/attributes/abilities`

export function useFetchAttributesAbilities() {
  const setAttributesAbilities = useSetAtom(abilitiesAtom)

  const { data } = useSWR<TAttributesAbilities[]>(ATTRIBUTESABILITIES_SWR_KEY(), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const abilities = arrayToObjectKey(["id"], data) as TAttributesAbilitiesRecordById
      setAttributesAbilities(abilities)
    }
  }, [data, setAttributesAbilities])
}

export function useAttributesAbilitiesState() {
  return useAtomValue(abilitiesAtom)
}
