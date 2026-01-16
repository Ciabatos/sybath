// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TCitiesCityTilesRecordByXY , TCitiesCityTilesParams, TCitiesCityTiles  } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { cityTilesAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateCitiesCityTiles( params: TCitiesCityTilesParams) {
  const { mutate } = useSWR<TCitiesCityTiles[]>(`/api/cities/city-tiles/${params.cityId}`)
  const setCitiesCityTiles = useSetAtom(cityTilesAtom)
  const cityTiles = useAtomValue(cityTilesAtom)

  function mutateCitiesCityTiles(optimisticParams: Partial<TCitiesCityTiles> | Partial<TCitiesCityTiles>[]) {
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
    
    setCitiesCityTiles(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateCitiesCityTiles }
}
