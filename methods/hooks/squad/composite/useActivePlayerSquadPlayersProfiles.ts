"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchActivePlayerSquadPlayersProfiles } from "@/methods/hooks/squad/core/useFetchActivePlayerSquadPlayersProfiles"
import { activePlayerSquadPlayersProfilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function useActivePlayerSquadPlayersProfiles() {
  const { playerId } = usePlayerId()

  useFetchActivePlayerSquadPlayersProfiles({ playerId })
  const activePlayerSquadPlayersProfiles = useAtomValue(activePlayerSquadPlayersProfilesAtom)

  return { activePlayerSquadPlayersProfiles }
}
