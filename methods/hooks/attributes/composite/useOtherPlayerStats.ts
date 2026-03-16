"use client"

import {
  useAttributesStatsState,
  useFetchAttributesStats,
} from "@/methods/hooks/attributes/core/useFetchAttributesStats"
import {
  useFetchOtherPlayerStats,
  useOtherPlayerStatsState,
} from "@/methods/hooks/attributes/core/useFetchOtherPlayerStats"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useOtherPlayerStats() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  useFetchAttributesStats()
  const stats = useAttributesStatsState()

  useFetchOtherPlayerStats({ playerId, otherPlayerId })
  const otherPlayerStats = useOtherPlayerStatsState()

  const combinedOtherPlayerStats = Object.entries(otherPlayerStats).map(([key, playerStat]) => ({
    ...playerStat,
    ...stats[playerStat.statId],
  }))

  return { stats, otherPlayerStats, combinedOtherPlayerStats }
}
