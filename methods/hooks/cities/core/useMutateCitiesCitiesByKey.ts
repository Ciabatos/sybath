// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TCitiesCitiesRecordByMapTileXMapTileY , TCitiesCitiesParams, TCitiesCities  } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { citiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateCitiesCities( params: TCitiesCitiesParams) {
  const { mutate } = useSWR<TCitiesCities[]>(`/api/cities/cities/${params.mapId}`)
  const setCitiesCities = useSetAtom(citiesAtom)
  

  function mutateCitiesCities(optimisticParams: Partial<TCitiesCities> | Partial<TCitiesCities>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]
    
    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      mapId: ``,
      mapTileX: ``,
      mapTileY: ``,
      name: ``,
      moveCost: ``,
      imageUrl: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["mapTileX", "mapTileY"], dataWithDefaults) as TCitiesCitiesRecordByMapTileXMapTileY
    
    const optimisticDataMergeWithOldData: TCitiesCitiesRecordByMapTileXMapTileY = {
       
      ...newObj,      
    }
    
    setCitiesCities(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateCitiesCities }
}
