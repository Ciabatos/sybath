// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TAllSkillsRecordById,
  TAllSkills,
  TAllSkillsFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/allSkills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { allSkillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateAllSkills` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ALLSKILLS_SWR_KEY = (params: TAllSkillsFetchParams) =>
  params.playerId != null ? `/api/attributes/rpc/get-all-skills/${params.playerId}` : null

export function useFetchAllSkills(params: TAllSkillsFetchParams) {
  const setAllSkills = useSetAtom(allSkillsAtom)

  const { data } = useSWR<TAllSkills[]>(ALLSKILLS_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const allSkills = arrayToObjectKey(["id"], data) as TAllSkillsRecordById
      setAllSkills(allSkills)
    }
  }, [data, setAllSkills])
}

export function useAllSkillsState() {
  return useAtomValue(allSkillsAtom)
}
