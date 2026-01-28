// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TWorldTerrainTypesRecordById, TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import useSWR from "swr"
import { terrainTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldTerrainTypes() {
  const { mutate } = useSWR<TWorldTerrainTypes[]>(`/api/world/terrain-types`)
  const terrainTypes = useAtomValue(terrainTypesAtom)

  function mutateWorldTerrainTypes(optimisticParams?: Partial<TWorldTerrainTypes> | Partial<TWorldTerrainTypes>[]) {
    if (!optimisticParams) {
      mutate()
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

    mutate(optimisticDataMergeWithOldDataArray, {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateWorldTerrainTypes }
}
