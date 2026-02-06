// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { TBuildingsBuildingsParams, TBuildingsBuildings } from "@/db/postgresMainDatabase/schemas/buildings/buildings"

export function useMutateBuildingsBuildings(params: TBuildingsBuildingsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/buildings/buildings/${params.cityId}`

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
