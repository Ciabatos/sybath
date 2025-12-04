// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TAttributesSkillsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { skillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchAttributesSkills() {
  const skills = useAtomValue(skillsAtom)
  const setAttributesSkills = useSetAtom(skillsAtom)

  const { data } = useSWR(`/api/attributes/skills`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["id"], data) as TAttributesSkillsRecordById) : {}
      setAttributesSkills(index)
      prevDataRef.current = data
    }
  }, [data, setAttributesSkills])

  return { skills }
}
