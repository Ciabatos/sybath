"use client"

import { doOtherPlayerKnowledgeAcceptAction } from "@/methods/actions/knowledge/doOtherPlayerKnowledgeAcceptAction"
import { doOtherPlayerKnowledgeDeclineAction } from "@/methods/actions/knowledge/doOtherPlayerKnowledgeDeclineAction"
import { doOtherPlayerKnowledgeRequestAction } from "@/methods/actions/knowledge/doOtherPlayerKnowledgeRequestAction"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { toast } from "sonner"

export function useOtherPlayerKnowledgeControls() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  async function inviteToKnowledge(knowledgeTypeId: number) {
    try {
      const result = await doOtherPlayerKnowledgeRequestAction({
        playerId,
        otherPlayerId,
        knowledgeTypeId,
      })

      if (!result.status) {
        toast.error(result?.message)
        return false
      }

      toast.success(result?.message)
      return true
    } catch (err) {
      console.error("Unexpected error in inviteToKnowledge:", err)
      toast.error("Unexpected error occurred. Please refresh the page.")
      return false
    }
  }

  async function acceptKnowledgeRequest(inviteId: number) {
    try {
      const result = await doOtherPlayerKnowledgeAcceptAction({ playerId, inviteId })

      if (!result.status) {
        toast.error(result?.message)
        return false
      }

      toast.success(result?.message)
      return true
    } catch (err) {
      console.error("Unexpected error in acceptKnowledgeRequest:", err)
      toast.error("Unexpected error occurred. Please refresh the page.")
      return false
    }
  }

  async function declineKnowledgeRequest(inviteId: number) {
    try {
      const result = await doOtherPlayerKnowledgeDeclineAction({ playerId, inviteId })

      if (!result.status) {
        toast.error(result?.message)
        return false
      }

      toast.success(result?.message)
      return true
    } catch (err) {
      console.error("Unexpected error in declineKnowledgeRequest:", err)
      toast.error("Unexpected error occurred. Please refresh the page.")
      return false
    }
  }

  return {
    inviteToKnowledge,
    inviteToKnownProfile: () => inviteToKnowledge(1),
    inviteToKnownSkills: () => inviteToKnowledge(2),
    inviteToKnownAbilities: () => inviteToKnowledge(3),
    inviteToKnownStats: () => inviteToKnowledge(4),
    inviteToKnownInventory: () => inviteToKnowledge(5),
    inviteToKnownPosition: () => inviteToKnowledge(6),
    acceptKnowledgeRequest,
    declineKnowledgeRequest,
  }
}
