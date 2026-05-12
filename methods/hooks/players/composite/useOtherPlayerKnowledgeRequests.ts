"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useFetchOtherPlayerKnowledgeRequests,
  useOtherPlayerKnowledgeRequestsState,
} from "@/methods/hooks/players/core/useFetchOtherPlayerKnowledgeRequests"

export function useOtherPlayerKnowledgeRequests() {
  const { playerId } = usePlayerId()

  useFetchOtherPlayerKnowledgeRequests({ playerId })
  const otherPlayerKnowledgeRequests = useOtherPlayerKnowledgeRequestsState()

  return { otherPlayerKnowledgeRequests }
}
