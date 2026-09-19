"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useActivePlayerSwitchProfilesState,
  useFetchActivePlayerSwitchProfiles,
} from "@/methods/hooks/players/core/useFetchActivePlayerSwitchProfiles"

export function useActivePlayerSwitchProfiles() {
  const { playerId } = usePlayerId()
  useFetchActivePlayerSwitchProfiles({ playerId })
  const activePlayerSwitchProfiles = useActivePlayerSwitchProfilesState()

  return { activePlayerSwitchProfiles }
}
