"use client"

import { doSwitchActivePlayerAction } from "@/methods/actions/players/doSwitchActivePlayerAction"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useActivePlayerSwitchProfilesState,
  useFetchActivePlayerSwitchProfiles,
} from "@/methods/hooks/players/core/useFetchActivePlayerSwitchProfiles"
import { useMutateActivePlayer } from "@/methods/hooks/players/core/useMutateActivePlayer"
import { toast } from "sonner"

export function useActivePlayerSwitchProfiles() {
  const { playerId } = usePlayerId()
  const { mutateActivePlayer } = useMutateActivePlayer()

  useFetchActivePlayerSwitchProfiles({ playerId })
  const activePlayerSwitchProfiles = useActivePlayerSwitchProfilesState()

  async function switchPlayer(newPlayerId: number) {
    try {
      const result = await doSwitchActivePlayerAction({ playerId: playerId, switchToPlayerId: newPlayerId })

      if (!result.status) {
        return toast.error(result?.message)
      }

      mutateActivePlayer([{ id: newPlayerId }])

      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in switchPlayer:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { activePlayerSwitchProfiles, switchPlayer }
}
