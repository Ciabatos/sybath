// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TWorldMapTilesMapRegionsRecordByRegionId,
  TWorldMapTilesMapRegionsParams,
  TWorldMapTilesMapRegions,
} from "@/db/postgresMainDatabase/schemas/world/mapTilesMapRegions"
import { mapTilesMapRegionsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldMapTilesMapRegions(params: TWorldMapTilesMapRegionsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/map-tiles-map-regions/${params.mapId}`
  const mapTilesMapRegions = useAtomValue(mapTilesMapRegionsAtom)

  function mutateWorldMapTilesMapRegions(optimisticParams?: Partial<TWorldMapTilesMapRegions>[]) {
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
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["regionId"], dataWithDefaults) as TWorldMapTilesMapRegionsRecordByRegionId

    const optimisticDataMergeWithOldData: TWorldMapTilesMapRegionsRecordByRegionId = {
      ...mapTilesMapRegions,
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

  return { mutateWorldMapTilesMapRegions }
}
