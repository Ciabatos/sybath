"use client"

import { useFetchAttributesStats } from "@/methods/hooks/attributes/core/useFetchAttributesStats"
import { useFetchPlayerStats } from "@/methods/hooks/attributes/core/useFetchPlayerStats"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { playerStatsAtom, statsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function usePlayerStats() {
  const { playerId } = usePlayerId()

  useFetchAttributesStats()
  const stats = useAtomValue(statsAtom)

  useFetchPlayerStats({ playerId })
  const playerStats = useAtomValue(playerStatsAtom)

  return { stats, playerStats }
}
