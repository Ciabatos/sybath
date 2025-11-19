// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"
import { skillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchSkills() {
  const skills = useAtomValue(skillsAtom)
  const setSkills = useSetAtom(skillsAtom)

  const { data } = useSWR(`/api/attributes/skills`, { refreshInterval: 3000 })

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
