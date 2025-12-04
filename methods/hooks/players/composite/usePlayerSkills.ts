"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchPlayerSkills } from "@/methods/hooks/players/core/useFetchPlayerSkills"

export function usePlayerSkills() {
  const { playerId } = usePlayerId()
  const { playerSkills } = useFetchPlayerSkills({ playerId })

  return { playerSkills }
}
