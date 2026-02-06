// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { TWorldMapTilesRecordByXY, TWorldMapTilesParams, TWorldMapTiles  } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { mapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldMapTiles( params: TWorldMapTilesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/map-tiles/${params.mapId}`
  const mapTiles = useAtomValue(mapTilesAtom)

  function mutateWorldMapTiles(optimisticParams?: Partial<TWorldMapTiles> | Partial<TWorldMapTiles>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]
    
    //MANUAL CODE - START

    const defaultValues = {
      mapId: ``,
      x: ``,
      y: ``,
      terrainTypeId: ``,
      landscapeTypeId: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
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
