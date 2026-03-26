// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TKnownPlayersPositionsRecordByXY,
  TKnownPlayersPositionsParams,
  TKnownPlayersPositions,
} from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import { knownPlayersPositionsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateKnownPlayersPositions(params: TKnownPlayersPositionsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-known-players-positions/${params.mapId}/${params.playerId}`
  const knownPlayersPositions = useAtomValue(knownPlayersPositionsAtom)

  function mutateKnownPlayersPositions(optimisticParams?: Partial<TKnownPlayersPositions>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      otherPlayerId: ``,
      x: ``,
      y: ``,
      imageMap: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TKnownPlayersPositionsRecordByXY

    const optimisticDataMergeWithOldData: TKnownPlayersPositionsRecordByXY = {
      ...knownPlayersPositions,
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

  return { mutateKnownPlayersPositions }
}
