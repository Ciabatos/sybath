// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TBuildingsBuildingsRecordByCityTileXCityTileY , TBuildingsBuildingsParams, TBuildingsBuildings  } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { buildingsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateBuildingsBuildings( params: TBuildingsBuildingsParams) {
  const { mutate } = useSWR<TBuildingsBuildings[]>(`/api/buildings/buildings/${params.cityId}`)
  const setBuildingsBuildings = useSetAtom(buildingsAtom)
  

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

    const newObj = arrayToObjectKey(["cityTileX", "cityTileY"], dataWithDefaults) as TBuildingsBuildingsRecordByCityTileXCityTileY
    
    const optimisticDataMergeWithOldData: TBuildingsBuildingsRecordByCityTileXCityTileY = {
       
      ...newObj,      
    }
    
    setBuildingsBuildings(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateBuildingsBuildings }
}
