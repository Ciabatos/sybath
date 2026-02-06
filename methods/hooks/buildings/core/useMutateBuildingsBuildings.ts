// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import { TBuildingsBuildings } from "@/db/postgresMainDatabase/schemas/buildings/buildings"




export function useMutateBuildingsBuildings() {
  const { mutate } = useSWRConfig()
  const key = `/api/buildings/buildings`
  

  function mutateBuildingsBuildings(optimisticParams?: Partial<TBuildingsBuildings> | Partial<TBuildingsBuildings>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }
    
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]
    
    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      cityId: ``,
      cityTileX: ``,
      cityTileY: ``,
      buildingTypeId: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    mutate(key, dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateBuildingsBuildings }
}
