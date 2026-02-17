// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import { TWorldMapTilesRecordByXY, TWorldMapTiles } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { mapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldMapTiles() {
  const { mutate } = useSWRConfig()
  const key = `/api/world/map-tiles`
  const mapTiles = useAtomValue(mapTilesAtom)

  function mutateWorldMapTiles(optimisticParams?: Partial<TWorldMapTiles>[]) {
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
      regionId: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TWorldMapTilesRecordByXY

    const optimisticDataMergeWithOldData: TWorldMapTilesRecordByXY = {
      ...mapTiles,
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

  return { mutateWorldMapTiles }
}
