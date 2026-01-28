// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TBuildingsBuildings } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import useSWR from "swr"




export function useMutateBuildingsBuildings() {
  const { mutate } = useSWR<TBuildingsBuildings[]>(`/api/buildings/buildings`)
  

  function mutateBuildingsBuildings(optimisticParams?: Partial<TBuildingsBuildings> | Partial<TBuildingsBuildings>[]) {
    if (!optimisticParams) {
      mutate()
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

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateBuildingsBuildings }
}
