"use client"

import {
  useFetchOtherPlayerKnowledgeRequests,
  useOtherPlayerKnowledgeRequestsState,
} from "@/methods/hooks/knowledge/core/useFetchOtherPlayerKnowledgeRequests"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useOtherPlayerKnowledgeRequests() {
  const { playerId } = usePlayerId()

  useFetchOtherPlayerKnowledgeRequests({ playerId })
  const otherPlayerKnowledgeRequests = useOtherPlayerKnowledgeRequestsState()

  return { otherPlayerKnowledgeRequests }
}
