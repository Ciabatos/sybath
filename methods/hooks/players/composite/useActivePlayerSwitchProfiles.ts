"use client"

import { doSwitchActivePlayerAction } from "@/methods/actions/players/doSwitchActivePlayerAction"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchActivePlayerSwitchProfiles } from "@/methods/hooks/players/core/useFetchActivePlayerSwitchProfiles"
import { useMutateActivePlayer } from "@/methods/hooks/players/core/useMutateActivePlayer"
import { activePlayerSwitchProfilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useActivePlayerSwitchProfiles() {
  const { playerId } = usePlayerId()
  const { mutateActivePlayer } = useMutateActivePlayer()

  useFetchActivePlayerSwitchProfiles({ playerId })
  const activePlayerSwitchProfiles = useAtomValue(activePlayerSwitchProfilesAtom)

  function switchPlayer(newPlayerId: number) {
    doSwitchActivePlayerAction({ playerId: playerId, switchToPlayerId: newPlayerId })
    mutateActivePlayer({ id: newPlayerId })
  }

  return { activePlayerSwitchProfiles, switchPlayer }
}
