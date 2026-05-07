"use client"

import { doSquadCreateAction } from "@/methods/actions/squad/doSquadCreateAction"
import { doSquadInviteAction } from "@/methods/actions/squad/doSquadInviteAction"
import { doSquadJoinAction } from "@/methods/actions/squad/doSquadJoinAction"
import { doSquadLeaveAction } from "@/methods/actions/squad/doSquadLeaveAction"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMutateActivePlayerSquad } from "@/methods/hooks/squad/core/useMutateActivePlayerSquad"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useFetchPlayerPosition, usePlayerPositionState } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { toast } from "sonner"

export type TJoinSquadParams = {
  squadInviteId: number
  mapId: number
  mapTileX: number
  mapTileY: number
}

export function useSquadControls() {
  const { mapId: playerMapId } = useMapId()
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()
  useFetchPlayerPosition({ mapId: playerMapId, playerId })
  const playerPosition = usePlayerPositionState()
  const [playerPos] = Object.values(playerPosition)
  const { selectPlayerPath } = usePlayerMovement()
  const { mutateActivePlayerSquad } = useMutateActivePlayerSquad({ playerId })

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

  async function joinSquad({ squadInviteId, mapId, mapTileX, mapTileY }: TJoinSquadParams) {
    try {
      if (!squadInviteId) return toast.error("No squad selected")
      if (mapId !== playerMapId) return toast.error("Squad is on a different map")
      if (!playerPosition[`${mapTileX},${mapTileY}`]) {
        const resultMovement = await selectPlayerPath({
          playerId: playerId,
          startX: playerPos.x,
          startY: playerPos.y,
          endX: mapTileX,
          endY: mapTileY,
        })

        if (!resultMovement) {
          return toast.error("Failed to move to the tile, cannot join")
        }
      }

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
