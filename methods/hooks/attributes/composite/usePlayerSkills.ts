"use client"

import {
  useAttributesSkillsState,
  useFetchAttributesSkills,
} from "@/methods/hooks/attributes/core/useFetchAttributesSkills"
import { useFetchPlayerSkills, usePlayerSkillsState } from "@/methods/hooks/attributes/core/useFetchPlayerSkills"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerSkills() {
  const { playerId } = usePlayerId()

  useFetchAttributesSkills()
  const skills = useAttributesSkillsState()

  useFetchPlayerSkills({ playerId })
  const playerSkills = usePlayerSkillsState()

  const combinedPlayerSkills = Object.entries(playerSkills).map(([key, playerSkill]) => ({
    ...playerSkill,
    ...skills[playerSkill.skillId],
  }))

  return { skills, playerSkills, combinedPlayerSkills }
}
