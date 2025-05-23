"use client"
import { skillsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchSkills() {
  const setSkills = useSetAtom(skillsAtom)
  const { data } = useSWR(`/api/skills`)

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setSkills(data)
      prevDataRef.current = data
    }
  }, [data])
}
