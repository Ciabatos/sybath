// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { TBuildingsBuildingsParams, TBuildingsBuildings  } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import useSWR from "swr"




export function useMutateBuildingsBuildings( params: TBuildingsBuildingsParams) {
  const { mutate } = useSWR<TBuildingsBuildings[]>(`/api/buildings/buildings/${params.cityId}`)
  

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
