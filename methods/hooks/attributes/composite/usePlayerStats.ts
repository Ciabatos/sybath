"use client"

import {
  useAttributesStatsState,
  useFetchAttributesStats,
} from "@/methods/hooks/attributes/core/useFetchAttributesStats"
import { useFetchPlayerStats, usePlayerStatsState } from "@/methods/hooks/attributes/core/useFetchPlayerStats"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function usePlayerStats() {
  const { playerId } = usePlayerId()

  useFetchAttributesStats()
  const stats = useAttributesStatsState()

  useFetchPlayerStats({ playerId })
  const playerStats = usePlayerStatsState()

  const combinedPlayerStats = Object.entries(playerStats).map(([key, playerStat]) => ({
    ...playerStat,
    ...stats[playerStat.statId],
  }))

  return { stats, playerStats, combinedPlayerStats }
}
