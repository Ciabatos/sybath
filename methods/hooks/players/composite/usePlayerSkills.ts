"use client"

import { useFetchPlayerSkills } from "@/methods/hooks/attributes/core/useFetchPlayerSkills"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerSkills() {
  const { playerId } = usePlayerId()
  const { playerSkills } = useFetchPlayerSkills({ playerId })

  return { playerSkills }
}
