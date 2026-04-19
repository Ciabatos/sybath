"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchSquadInvites, useSquadInvitesState } from "@/methods/hooks/squad/core/useFetchSquadInvites"

export function useSquadInvites() {
  const { playerId } = usePlayerId()

  useFetchSquadInvites({ playerId })
  const squadInvites = useSquadInvitesState()

  return { squadInvites }
}
