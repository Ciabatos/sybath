"use client"

import { useFetchPlayerEnergy, usePlayerEnergyState } from "@/methods/hooks/attributes/core/useFetchPlayerEnergy"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerEnergyBar() {
  const { playerId } = usePlayerId()

  useFetchPlayerEnergy({ playerId })
  const playerEnergy = usePlayerEnergyState()

  return { playerEnergy }
}
