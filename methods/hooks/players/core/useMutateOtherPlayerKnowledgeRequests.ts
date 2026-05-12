// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId,
  TOtherPlayerKnowledgeRequestsParams,
  TOtherPlayerKnowledgeRequests,
} from "@/db/postgresMainDatabase/schemas/players/otherPlayerKnowledgeRequests"
import { otherPlayerKnowledgeRequestsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerKnowledgeRequests(params: TOtherPlayerKnowledgeRequestsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/players/rpc/get-other-player-knowledge-requests/${params.playerId}`
  const otherPlayerKnowledgeRequests = useAtomValue(otherPlayerKnowledgeRequestsAtom)

  function mutateOtherPlayerKnowledgeRequests(optimisticParams?: Partial<TOtherPlayerKnowledgeRequests>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      otherPlayerKnowledgeRequestId: ``,
      otherPlayerId: ``,
      name: ``,
      secondName: ``,
      nickname: ``,
      imagePortrait: ``,
      knowledgeTypeId: ``,
      createdAt: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(
      ["otherPlayerKnowledgeRequestId"],
      dataWithDefaults,
    ) as TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId

    const optimisticDataMergeWithOldData: TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId = {
      ...otherPlayerKnowledgeRequests,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, () => fetchFresh(key), {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateOtherPlayerKnowledgeRequests }
}
