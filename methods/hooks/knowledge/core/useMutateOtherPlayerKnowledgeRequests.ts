// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId,
  TOtherPlayerKnowledgeRequestsFetchParams,
  TOtherPlayerKnowledgeRequests,
} from "@/db/postgresMainDatabase/schemas/knowledge/otherPlayerKnowledgeRequests"
import { OTHERPLAYERKNOWLEDGEREQUESTS_SWR_KEY } from "@/methods/hooks/knowledge/core/useFetchOtherPlayerKnowledgeRequests"
import { otherPlayerKnowledgeRequestsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerKnowledgeRequests(params: TOtherPlayerKnowledgeRequestsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = OTHERPLAYERKNOWLEDGEREQUESTS_SWR_KEY(params)
  const otherPlayerKnowledgeRequests = useAtomValue(otherPlayerKnowledgeRequestsAtom)

  function mutateOtherPlayerKnowledgeRequests(optimisticParams?: Partial<TOtherPlayerKnowledgeRequests>[]) {
    if (!key) return

    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    /*
      Uzupełnij wartości domyślne dla `optimisticParams`. Wcześniej generator
      wpisywał tu `` (pusty string) dla KAŻDEGO pola, co dla pól liczbowych
      oznaczało `mapId: ""` — bezsensowną daną, która kompilowała się tylko
      dlatego, że `Partial<T>` maskuje typ. Uzupełniaj ręcznie albo zostaw `{}`,
      jeśli nie potrzebujesz defaults.
    */
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
