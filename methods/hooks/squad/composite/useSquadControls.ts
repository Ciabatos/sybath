"use client"

import { doSquadCreateAction } from "@/methods/actions/squad/doSquadCreateAction"
import { doSquadDeleteAction } from "@/methods/actions/squad/doSquadDeleteAction"
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

  async function deleteSquad() {
    try {
      const result = await doSquadDeleteAction({ playerId: playerId })

      if (!result.status) {
        return result.message
      }

      mutateActivePlayerSquad()
      return result.message
    } catch (err) {
      console.error("Unexpected error in deleteSquad:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { createSquad, deleteSquad }
}
