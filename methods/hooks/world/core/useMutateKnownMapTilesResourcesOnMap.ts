// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY,
  TKnownMapTilesResourcesOnMapParams,
  TKnownMapTilesResourcesOnMap,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap"
import { knownMapTilesResourcesOnMapAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateKnownMapTilesResourcesOnMap(params: TKnownMapTilesResourcesOnMapParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-known-map-tiles-resources-on-map/${params.mapId}/${params.playerId}`
  const knownMapTilesResourcesOnMap = useAtomValue(knownMapTilesResourcesOnMapAtom)

  function mutateKnownMapTilesResourcesOnMap(optimisticParams?: Partial<TKnownMapTilesResourcesOnMap>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      mapTileX: ``,
      mapTileY: ``,
      itemIds: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(
      ["mapTileX", "mapTileY"],
      dataWithDefaults,
    ) as TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY

    const optimisticDataMergeWithOldData: TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY = {
      ...knownMapTilesResourcesOnMap,
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

  return { mutateKnownMapTilesResourcesOnMap }
}
