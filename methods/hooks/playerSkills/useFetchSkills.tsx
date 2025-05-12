"use client"
import { skillsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchSkills() {
  const setSkills = useSetAtom(skillsAtom)
  const { data, error, isLoading } = useSWR(`/api/skills`)

  useEffect(() => {
    setSkills(data)
  }, [data, error, isLoading])
}
