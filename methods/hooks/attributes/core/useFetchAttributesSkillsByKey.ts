// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TAttributesSkillsRecordById, TAttributesSkills, TAttributesSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { skillsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAttributesSkillsByKey( params: TAttributesSkillsParams ) {
  const setAttributesSkills = useSetAtom(skillsAtom)
  
  const { data } = useSWR<TAttributesSkills[]>(`/api/attributes/skills/${params.id}`, { refreshInterval: 3000 })

  const skills = data
  ? (arrayToObjectKey(["id"], data) as TAttributesSkillsRecordById)
  : undefined

  useEffect(() => {
    if (skills) {
      setAttributesSkills(skills)
    }
  }, [skills, setAttributesSkills])

  return { skills }
}
