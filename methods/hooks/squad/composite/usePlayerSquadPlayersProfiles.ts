"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useFetchSquadPlayersProfiles,
  useSquadPlayersProfilesState,
} from "@/methods/hooks/squad/core/useFetchSquadPlayersProfiles"

export default function usePlayerSquadPlayersProfiles() {
  const { playerId } = usePlayerId()

  useFetchSquadPlayersProfiles({ playerId })
  const squadPlayersProfiles = useSquadPlayersProfilesState()
  return { squadPlayersProfiles }
}
