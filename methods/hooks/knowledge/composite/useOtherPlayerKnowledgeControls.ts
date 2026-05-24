"use client"

import { doOtherPlayerKnowledgeRequestAction } from "@/methods/actions/knowledge/doOtherPlayerKnowledgeRequestAction"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { toast } from "sonner"

export function useOtherPlayerKnowledgeControls() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  async function inviteToKnownProfile() {
    try {
      const result = await doOtherPlayerKnowledgeRequestAction({
        playerId: playerId,
        otherPlayerId: otherPlayerId,
        knowledgeTypeId: 1,
      })

      if (!result.status) {
        return toast.error(result?.message)
      }

      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in inviteToKnownProfile:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function inviteToKnownSkills() {
    try {
      const result = await doOtherPlayerKnowledgeRequestAction({
        playerId: playerId,
        otherPlayerId: otherPlayerId,
        knowledgeTypeId: 2,
      })

      if (!result.status) {
        return toast.error(result?.message)
      }

      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in inviteToKnownSkills:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function inviteToKnownAbilities() {
    try {
      const result = await doOtherPlayerKnowledgeRequestAction({
        playerId: playerId,
        otherPlayerId: otherPlayerId,
        knowledgeTypeId: 3,
      })

      if (!result.status) {
        return toast.error(result?.message)
      }

      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in inviteToKnownAbilities:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function inviteToKnownStats() {
    try {
      const result = await doOtherPlayerKnowledgeRequestAction({
        playerId: playerId,
        otherPlayerId: otherPlayerId,
        knowledgeTypeId: 4,
      })

      if (!result.status) {
        return toast.error(result?.message)
      }

      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in inviteToKnownStats:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function inviteToKnownInventory() {
    try {
      const result = await doOtherPlayerKnowledgeRequestAction({
        playerId: playerId,
        otherPlayerId: otherPlayerId,
        knowledgeTypeId: 5,
      })

      if (!result.status) {
        return toast.error(result?.message)
      }

      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in inviteToKnownInventory:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function inviteToKnownPosition() {
    try {
      const result = await doOtherPlayerKnowledgeRequestAction({
        playerId: playerId,
        otherPlayerId: otherPlayerId,
        knowledgeTypeId: 6,
      })

      if (!result.status) {
        return toast.error(result?.message)
      }

      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in inviteToKnownPosition:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return {
    inviteToKnownProfile,
    inviteToKnownSkills,
    inviteToKnownAbilities,
    inviteToKnownStats,
    inviteToKnownInventory,
    inviteToKnownPosition,
  }
}
