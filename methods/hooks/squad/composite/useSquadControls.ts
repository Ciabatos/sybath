"use client"

import { doSquadCreateAction } from "@/methods/actions/squad/doSquadCreateAction"
import { doSquadLeaveAction } from "@/methods/actions/squad/doSquadLeaveAction"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMutateActivePlayerSquad } from "@/methods/hooks/squad/core/useMutateActivePlayerSquad"

export function useSquadControls() {
  const { playerId } = usePlayerId()
  const { mutateActivePlayerSquad } = useMutateActivePlayerSquad({ playerId })

  async function createSquad() {
    try {
      const result = await doSquadCreateAction({ playerId: playerId })

      if (!result.status) {
        return result.message
      }

      mutateActivePlayerSquad()
      return result.message
    } catch (err) {
      console.error("Unexpected error in createSquad:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function leaveSquad() {
    try {
      const result = await doSquadLeaveAction({ playerId: playerId })

      if (!result.status) {
        return result.message
      }

      mutateActivePlayerSquad()
      return result.message
    } catch (err) {
      console.error("Unexpected error in leaveSquad:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { createSquad, leaveSquad }
}
