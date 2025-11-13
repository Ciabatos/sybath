// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TAttributesSkillsRecordById, TAttributesSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { skillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchSkillsByKey( params: TAttributesSkillsParams ) {
  const skills = useAtomValue(skillsAtom)
  const setSkills = useSetAtom(skillsAtom)
  
  const { data } = useSWR(`/api/attributes/skills/${params.id}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeyId("id", data) as TAttributesSkillsRecordById) : {}
      setSkills(index)
      prevDataRef.current = data
    }
  }, [data, setSkills])

  return { skills }
}
