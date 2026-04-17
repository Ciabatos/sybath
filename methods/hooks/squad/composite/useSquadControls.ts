"use client"

import { doSquadCreateAction } from "@/methods/actions/squad/doSquadCreateAction"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useSquadControls() {
  const { playerId } = usePlayerId()

  async function createSquad() {
    try {
      const result = await doSquadCreateAction({ playerId: playerId })

      if (!result.status) {
        return result.message
      }

      return result.message
    } catch (err) {
      console.error("Unexpected error in createSquad:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function deleteSquad() {
    try {
      const result = await doSquadCreateAction({ playerId: playerId })

      if (!result.status) {
        return result.message
      }

      return result.message
    } catch (err) {
      console.error("Unexpected error in deleteSquad:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { createSquad }
}
