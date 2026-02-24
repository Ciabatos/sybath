"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchOtherSquadPlayersProfiles } from "@/methods/hooks/squad/core/useFetchOtherSquadPlayersProfiles"
import { otherSquadPlayersProfilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function useOtherSquadPlayersProfiles(squadId: number) {
  const { playerId } = usePlayerId()

  useFetchOtherSquadPlayersProfiles({ playerId, squadId })
  const otherSquadPlayersProfiles = useAtomValue(otherSquadPlayersProfilesAtom)

  return { otherSquadPlayersProfiles }
}
