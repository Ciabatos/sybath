// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TAllSkillsRecordById,
  TAllSkills,
  TAllSkillsParams,
} from "@/db/postgresMainDatabase/schemas/attributes/allSkills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { allSkillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAllSkills(params: TAllSkillsParams) {
  const setAllSkills = useSetAtom(allSkillsAtom)

  const { data } = useSWR<TAllSkills[]>(`/api/attributes/rpc/get-all-skills/${params.playerId}`, {
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
