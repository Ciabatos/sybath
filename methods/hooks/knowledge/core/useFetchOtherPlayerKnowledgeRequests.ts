// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId,
  TOtherPlayerKnowledgeRequests,
  TOtherPlayerKnowledgeRequestsFetchParams,
} from "@/db/postgresMainDatabase/schemas/knowledge/otherPlayerKnowledgeRequests"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerKnowledgeRequestsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateOtherPlayerKnowledgeRequests` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const OTHERPLAYERKNOWLEDGEREQUESTS_SWR_KEY = (params: TOtherPlayerKnowledgeRequestsFetchParams) =>
  params.playerId != null ? `/api/knowledge/rpc/get-other-player-knowledge-requests/${params.playerId}` : null

export function useFetchOtherPlayerKnowledgeRequests(params: TOtherPlayerKnowledgeRequestsFetchParams) {
  const setOtherPlayerKnowledgeRequests = useSetAtom(otherPlayerKnowledgeRequestsAtom)

  const { data } = useSWR<TOtherPlayerKnowledgeRequests[]>(OTHERPLAYERKNOWLEDGEREQUESTS_SWR_KEY(params), {
    refreshInterval: 3000,
  })

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
