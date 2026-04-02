"use client"

import {
  useAttributesSkillsState,
  useFetchAttributesSkills,
} from "@/methods/hooks/attributes/core/useFetchAttributesSkills"

export function useAllSKills() {
  useFetchAttributesSkills()
  const skills = useAttributesSkillsState()

  return { skills }
}
