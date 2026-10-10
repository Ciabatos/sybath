// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TAllAbilitiesRecordById,
  TAllAbilities,
  TAllAbilitiesFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/allAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { allAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateAllAbilities` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ALLABILITIES_SWR_KEY = (params: TAllAbilitiesFetchParams) =>
  params.playerId != null ? `/api/attributes/rpc/get-all-abilities/${params.playerId}` : null

export function useFetchAllAbilities(params: TAllAbilitiesFetchParams) {
  const setAllAbilities = useSetAtom(allAbilitiesAtom)

  const { data } = useSWR<TAllAbilities[]>(ALLABILITIES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const allAbilities = arrayToObjectKey(["id"], data) as TAllAbilitiesRecordById
      setAllAbilities(allAbilities)
    }
  }, [data, setAllAbilities])
}

export function useAllAbilitiesState() {
  return useAtomValue(allAbilitiesAtom)
}
