// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import {
  TKnownMapTilesResourcesOnTile,
  TKnownMapTilesResourcesOnTileParams,
  TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnTile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { fetchFresh } from "@/providers/swr-fetchers"
import { knownMapTilesResourcesOnTileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { useSWRConfig } from "swr"

export function useMutateKnownMapTilesResourcesOnTile(params: TKnownMapTilesResourcesOnTileParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-known-map-tiles-resources-on-tile/${params.mapId}/${params.mapTileX}/${params.mapTileY}/${params.playerId}`
  const knownMapTilesResourcesOnTile = useAtomValue(knownMapTilesResourcesOnTileAtom)

  function mutateKnownMapTilesResourcesOnTile(optimisticParams?: Partial<TKnownMapTilesResourcesOnTile>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key), { revalidate: true })
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      mapTilesResourceId: ``,
      itemId: ``,
      quantity: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(
      ["mapTilesResourceId"],
      dataWithDefaults,
    ) as TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId

    const optimisticDataMergeWithOldData: TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId = {
      ...knownMapTilesResourcesOnTile,
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

  return { mutateKnownMapTilesResourcesOnTile }
}
