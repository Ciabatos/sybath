// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TKnownMapRegionRecordByMapTileXMapTileY,
  TKnownMapRegionParams,
  TKnownMapRegion,
} from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { knownMapRegionAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateKnownMapRegion(params: TKnownMapRegionParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-known-map-region/${params.mapId}/${params.playerId}/${params.regionType}`
  const knownMapRegion = useAtomValue(knownMapRegionAtom)

  function mutateKnownMapRegion(optimisticParams?: Partial<TKnownMapRegion>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      regionId: ``,
      mapId: ``,
      mapTileX: ``,
      mapTileY: ``,
      regionName: ``,
      imageFill: ``,
      imageOutline: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(
      ["mapTileX", "mapTileY"],
      dataWithDefaults,
    ) as TKnownMapRegionRecordByMapTileXMapTileY

    const optimisticDataMergeWithOldData: TKnownMapRegionRecordByMapTileXMapTileY = {
      ...knownMapRegion,
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

  return { mutateKnownMapRegion }
}
