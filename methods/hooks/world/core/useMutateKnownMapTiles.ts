// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TKnownMapTilesRecordByXY,
  TKnownMapTilesParams,
  TKnownMapTiles,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { knownMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateKnownMapTiles(params: TKnownMapTilesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-known-map-tiles/${params.mapId}/${params.playerId}`
  const knownMapTiles = useAtomValue(knownMapTilesAtom)

  function mutateKnownMapTiles(optimisticParams?: Partial<TKnownMapTiles>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      mapId: ``,
      x: ``,
      y: ``,
      terrainTypeId: ``,
      landscapeTypeId: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TKnownMapTilesRecordByXY

    const optimisticDataMergeWithOldData: TKnownMapTilesRecordByXY = {
      ...knownMapTiles,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, optimisticDataMergeWithOldDataArray, {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateKnownMapTiles }
}
