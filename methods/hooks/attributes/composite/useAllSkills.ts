"use client"

import { useAllSkillsState, useFetchAllSkills } from "@/methods/hooks/attributes/core/useFetchAllSkills"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useAllSKills() {
  const { playerId } = usePlayerId()
  useFetchAllSkills({ playerId })
  const allSkills = useAllSkillsState()

  return { allSkills }
}
