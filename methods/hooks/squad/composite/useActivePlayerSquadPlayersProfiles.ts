"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useActivePlayerSquadPlayersProfilesState,
  useFetchActivePlayerSquadPlayersProfiles,
} from "@/methods/hooks/squad/core/useFetchActivePlayerSquadPlayersProfiles"

export default function useActivePlayerSquadPlayersProfiles() {
  const { playerId } = usePlayerId()

  useFetchActivePlayerSquadPlayersProfiles({ playerId })
  const activePlayerSquadPlayersProfiles = useActivePlayerSquadPlayersProfilesState()

  return { activePlayerSquadPlayersProfiles }
}
