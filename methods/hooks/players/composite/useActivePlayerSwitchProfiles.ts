"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchActivePlayerSwitchProfiles } from "@/methods/hooks/players/core/useFetchActivePlayerSwitchProfiles"
import { activePlayerSwitchProfilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useActivePlayerSwitchProfiles() {
  const { playerId } = usePlayerId()

  useFetchActivePlayerSwitchProfiles({ playerId })
  const activePlayerSwitchProfiles = useAtomValue(activePlayerSwitchProfilesAtom)

  return { activePlayerSwitchProfiles }
}
