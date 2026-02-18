// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TWorldMapTilesMapRegionsRecordByMapTileXMapTileY,
  TWorldMapTilesMapRegions,
} from "@/db/postgresMainDatabase/schemas/world/mapTilesMapRegions"
import { mapTilesMapRegionsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldMapTilesMapRegions() {
  const { mutate } = useSWRConfig()
  const key = `/api/world/map-tiles-map-regions`
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

    const newObj = arrayToObjectKey(
      ["mapTileX", "mapTileY"],
      dataWithDefaults,
    ) as TWorldMapTilesMapRegionsRecordByMapTileXMapTileY

    const optimisticDataMergeWithOldData: TWorldMapTilesMapRegionsRecordByMapTileXMapTileY = {
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
