// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId,
  TOtherPlayerKnowledgeRequests,
  TOtherPlayerKnowledgeRequestsParams,
} from "@/db/postgresMainDatabase/schemas/knowledge/otherPlayerKnowledgeRequests"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerKnowledgeRequestsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchOtherPlayerKnowledgeRequests(params: TOtherPlayerKnowledgeRequestsParams) {
  const setOtherPlayerKnowledgeRequests = useSetAtom(otherPlayerKnowledgeRequestsAtom)

  const { data } = useSWR<TOtherPlayerKnowledgeRequests[]>(
    `/api/knowledge/rpc/get-other-player-knowledge-requests/${params.playerId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const otherPlayerKnowledgeRequests = arrayToObjectKey(
        ["otherPlayerKnowledgeRequestId"],
        data,
      ) as TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId
      setOtherPlayerKnowledgeRequests(otherPlayerKnowledgeRequests)
    }
  }, [data, setOtherPlayerKnowledgeRequests])
}

export function useOtherPlayerKnowledgeRequestsState() {
  return useAtomValue(otherPlayerKnowledgeRequestsAtom)
}
