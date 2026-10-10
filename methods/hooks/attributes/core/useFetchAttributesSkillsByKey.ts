// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TAttributesSkillsRecordById,
  TAttributesSkills,
  TAttributesSkillsParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { skillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateAttributesSkills` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ATTRIBUTESSKILLS_SWR_KEY_BY_KEY = (params: TAttributesSkillsParamsFetchParams) =>
  params.id != null ? `/api/attributes/skills/${params.id}` : null

export function useFetchAttributesSkillsByKey(params: TAttributesSkillsParamsFetchParams) {
  const setAttributesSkills = useSetAtom(skillsAtom)

  const { data } = useSWR<TAttributesSkills[]>(ATTRIBUTESSKILLS_SWR_KEY_BY_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const skills = arrayToObjectKey(["id"], data) as TAttributesSkillsRecordById
      setAttributesSkills(skills)
    }
  }, [data, setAttributesSkills])
}

export function useAttributesSkillsState() {
  return useAtomValue(skillsAtom)
}
