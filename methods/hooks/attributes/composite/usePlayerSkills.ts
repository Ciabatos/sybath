"use client"

import { useFetchAttributesSkills } from "@/methods/hooks/attributes/core/useFetchAttributesSkills"
import { useFetchPlayerSkills } from "@/methods/hooks/attributes/core/useFetchPlayerSkills"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { playerSkillsAtom, skillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerSkills() {
  const { playerId } = usePlayerId()
  useFetchAttributesSkills()
  const skills = useAtomValue(skillsAtom)

  useFetchPlayerSkills({ playerId })
  const playerSkills = useAtomValue(playerSkillsAtom)

  const combinedPlayerSkills = Object.entries(playerSkills).map(([key, playerSkill]) => ({
    ...playerSkill,
    ...skills[playerSkill.skillId],
  }))

  return { skills, playerSkills, combinedPlayerSkills }
}
