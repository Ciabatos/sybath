// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { TCitiesCitiesParams, TCitiesCities  } from "@/db/postgresMainDatabase/schemas/cities/cities"
import useSWR from "swr"




export function useMutateCitiesCities( params: TCitiesCitiesParams) {
  const { mutate } = useSWR<TCitiesCities[]>(`/api/cities/cities/${params.mapId}`)
  

  function mutateCitiesCities(optimisticParams?: Partial<TCitiesCities> | Partial<TCitiesCities>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

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

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateCitiesCities }
}
