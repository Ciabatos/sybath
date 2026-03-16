"use client"

import {
  useAttributesSkillsState,
  useFetchAttributesSkills,
} from "@/methods/hooks/attributes/core/useFetchAttributesSkills"
import {
  useFetchOtherPlayerSkills,
  useOtherPlayerSkillsState,
} from "@/methods/hooks/attributes/core/useFetchOtherPlayerSkills"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useOtherPlayerSkills() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  useFetchAttributesSkills()
  const skills = useAttributesSkillsState()

  useFetchOtherPlayerSkills({ playerId, otherPlayerId })
  const otherPlayerSkills = useOtherPlayerSkillsState()

  const combinedOtherPlayerSkills = Object.entries(otherPlayerSkills).map(([key, playerSkill]) => ({
    ...playerSkill,
    ...skills[playerSkill.skillId],
  }))

  return { skills, otherPlayerSkills, combinedOtherPlayerSkills }
}
