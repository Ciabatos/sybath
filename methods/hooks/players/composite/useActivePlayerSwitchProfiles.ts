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

  async function switchPlayer(newPlayerId: number) {
    try {
      const result = await doSwitchActivePlayerAction({ playerId: playerId, switchToPlayerId: newPlayerId })
      console.log(result)
      if (!result.status) {
        return result.message
      }

      mutateActivePlayer({ id: newPlayerId })
    } catch (err) {
      console.error("Unexpected error in switchPlayer:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { activePlayerSwitchProfiles, switchPlayer }
}
