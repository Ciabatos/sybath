// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TBuildingsBuildingTypesRecordById , TBuildingsBuildingTypesParams, TBuildingsBuildingTypes  } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { buildingTypesAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateBuildingsBuildingTypes( params: TBuildingsBuildingTypesParams) {
  const { mutate } = useSWR<TBuildingsBuildingTypes[]>(`/api/buildings/building-types/${params.id}`)
  const setBuildingsBuildingTypes = useSetAtom(buildingTypesAtom)
  const buildingTypes = useAtomValue(buildingTypesAtom)

  function mutateBuildingsBuildingTypes(optimisticParams: Partial<TBuildingsBuildingTypes> | Partial<TBuildingsBuildingTypes>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]
    
    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      imageUrl: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TBuildingsBuildingTypesRecordById
    
    const optimisticDataMergeWithOldData: TBuildingsBuildingTypesRecordById = {
      ...buildingTypes, 
      ...newObj,      
    }
    
    setBuildingsBuildingTypes(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateBuildingsBuildingTypes }
}
