"use client"

import { useFetchAttributesPlayerSkillsByKey } from "@/methods/hooks/attributes/core/useFetchAttributesPlayerSkillsByKey"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerSkills() {
  const { playerId } = usePlayerId()
  const { playerSkills } = useFetchAttributesPlayerSkillsByKey({ playerId })

  return { playerSkills }
}
