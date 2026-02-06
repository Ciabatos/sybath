// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import { TCitiesCityTilesRecordByXY, TCitiesCityTiles } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { cityTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateCitiesCityTiles() {
  const { mutate } = useSWRConfig()
  const key = `/api/cities/city-tiles`
  const cityTiles = useAtomValue(cityTilesAtom)

  function mutateCitiesCityTiles(optimisticParams?: Partial<TCitiesCityTiles> | Partial<TCitiesCityTiles>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      cityId: ``,
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

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TCitiesCityTilesRecordByXY

    const optimisticDataMergeWithOldData: TCitiesCityTilesRecordByXY = {
      ...cityTiles,
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

  return { mutateCitiesCityTiles }
}
