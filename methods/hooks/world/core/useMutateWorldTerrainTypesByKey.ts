// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { TWorldTerrainTypesRecordById, TWorldTerrainTypesParams, TWorldTerrainTypes  } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { terrainTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldTerrainTypes( params: TWorldTerrainTypesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/terrain-types/${params.id}`
  const terrainTypes = useAtomValue(terrainTypesAtom)

  function mutateWorldTerrainTypes(optimisticParams?: Partial<TWorldTerrainTypes> | Partial<TWorldTerrainTypes>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]
    
    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      moveCost: ``,
      imageUrl: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TWorldTerrainTypesRecordById
    
    const optimisticDataMergeWithOldData: TWorldTerrainTypesRecordById = {
      ...terrainTypes,
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

  return { mutateWorldTerrainTypes }
}
