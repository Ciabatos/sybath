"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useFetchOtherSquadPlayersProfiles,
  useOtherSquadPlayersProfilesState,
} from "@/methods/hooks/squad/core/useFetchOtherSquadPlayersProfiles"

export default function useOtherSquadPlayersProfiles(squadId: number) {
  const { playerId } = usePlayerId()

  useFetchOtherSquadPlayersProfiles({ playerId, squadId })
  const otherSquadPlayersProfiles = useOtherSquadPlayersProfilesState()

  return { otherSquadPlayersProfiles }
}
