// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TAttributesSkillsRecordById, TAttributesSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { skillsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAttributesSkills() {
  const setAttributesSkills = useSetAtom(skillsAtom)
  
  const { data } = useSWR<TAttributesSkills[]>(`/api/attributes/skills`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const skills = arrayToObjectKey(["id"], data) as TAttributesSkillsRecordById
      setAttributesSkills(skills)
    }
  }, [data, setAttributesSkills])
}
