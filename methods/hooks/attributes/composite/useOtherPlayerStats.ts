"use client"

import { useFetchAttributesStats } from "@/methods/hooks/attributes/core/useFetchAttributesStats"
import { useFetchOtherPlayerStats } from "@/methods/hooks/attributes/core/useFetchOtherPlayerStats"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { otherPlayerStatsAtom, statsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useOtherPlayerStats() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  useFetchAttributesStats()
  const stats = useAtomValue(statsAtom)

  useFetchOtherPlayerStats({ playerId, otherPlayerId })
  const otherPlayerStats = useAtomValue(otherPlayerStatsAtom)

  const combinedOtherPlayerStats = Object.entries(otherPlayerStats).map(([key, playerStat]) => ({
    ...playerStat,
    ...stats[playerStat.statId],
  }))

  return { stats, otherPlayerStats, combinedOtherPlayerStats }
}
