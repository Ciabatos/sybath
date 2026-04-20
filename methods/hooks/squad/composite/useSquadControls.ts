"use client"

import { doSquadCreateAction } from "@/methods/actions/squad/doSquadCreateAction"
import { doSquadInviteAction } from "@/methods/actions/squad/doSquadInviteAction"
import { doSquadJoinAction } from "@/methods/actions/squad/doSquadJoinAction"
import { doSquadLeaveAction } from "@/methods/actions/squad/doSquadLeaveAction"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useMutateActivePlayerSquad } from "@/methods/hooks/squad/core/useMutateActivePlayerSquad"
import { toast } from "sonner"

export function useSquadControls() {
  const { playerId } = usePlayerId()
  const { mutateActivePlayerSquad } = useMutateActivePlayerSquad({ playerId })
  const otherPlayerId = useOtherPlayerId()

  async function createSquad() {
    try {
      const result = await doSquadCreateAction({ playerId: playerId })

      if (!result.status) {
        return toast.error(result?.message)
      }

      mutateActivePlayerSquad()
      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in createSquad:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function leaveSquad() {
    try {
      const result = await doSquadLeaveAction({ playerId: playerId })

      if (!result.status) {
        return toast.error(result?.message)
      }

      mutateActivePlayerSquad()
      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in leaveSquad:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function inviteToSquad(inviteType: number, squadRole: number) {
    try {
      const result = await doSquadInviteAction({
        playerId: playerId,
        invitedPlayerId: otherPlayerId,
        inviteType: inviteType,
        squadRole: squadRole,
      })

      if (!result.status) {
        return toast.error(result?.message)
      }

      mutateActivePlayerSquad()
      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in inviteToSquad:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  async function joinSquad(squadInviteId: number) {
    try {
      const result = await doSquadJoinAction({ playerId: playerId, squadInviteId: squadInviteId })

      if (!result.status) {
        return toast.error(result?.message)
      }

      mutateActivePlayerSquad()
      return toast.success(result?.message)
    } catch (err) {
      console.error("Unexpected error in joinSquad:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { createSquad, leaveSquad, inviteToSquad, joinSquad }
}
