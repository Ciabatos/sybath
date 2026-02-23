"use client"

import { useFetchAttributesSkills } from "@/methods/hooks/attributes/core/useFetchAttributesSkills"
import { useFetchOtherPlayerSkills } from "@/methods/hooks/attributes/core/useFetchOtherPlayerSkills"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { otherPlayerSkillsAtom, skillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useOtherPlayerSkills() {
  const { playerId } = usePlayerId()
  const otherPlayerMaskId = useOtherPlayerId()

  useFetchAttributesSkills()
  const skills = useAtomValue(skillsAtom)

  useFetchOtherPlayerSkills({ playerId, otherPlayerMaskId })
  const otherPlayerSkills = useAtomValue(otherPlayerSkillsAtom)

  const combinedOtherPlayerSkills = Object.entries(otherPlayerSkills).map(([key, playerSkill]) => ({
    ...playerSkill,
    ...skills[playerSkill.skillId],
  }))

  return { skills, otherPlayerSkills, combinedOtherPlayerSkills }
}
