// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TWorldTerrainTypesRecordById, TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { terrainTypesAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldTerrainTypes() {
  const { mutate } = useSWR<TWorldTerrainTypes[]>(`/api/world/terrain-types`)
  const setWorldTerrainTypes = useSetAtom(terrainTypesAtom)
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
    
    setWorldTerrainTypes(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateWorldTerrainTypes }
}
