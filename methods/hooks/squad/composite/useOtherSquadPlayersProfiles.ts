"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useOtherSquadId } from "@/methods/hooks/squad/composite/useOtherSquadId"
import {
  useFetchOtherSquadPlayersProfiles,
  useOtherSquadPlayersProfilesState,
} from "@/methods/hooks/squad/core/useFetchOtherSquadPlayersProfiles"

export default function useOtherSquadPlayersProfiles() {
  const { playerId } = usePlayerId()
  const squadId = useOtherSquadId()
  useFetchOtherSquadPlayersProfiles({ playerId, squadId })
  const otherSquadPlayersProfiles = useOtherSquadPlayersProfilesState()

  return { otherSquadPlayersProfiles }
}
