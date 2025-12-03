"use client"

import { useFetchPlayerId } from "@/methods/hooks/players/core/useFetchPlayerId"
import { useFetchPlayerSkills } from "@/methods/hooks/players/core/useFetchPlayerSkills"

export function usePlayerSkills() {
  const { playerId } = useFetchPlayerId()
  const { playerSkills } = useFetchPlayerSkills({ playerId })

  return { playerSkills }
}
