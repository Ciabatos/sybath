// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TWorldTerrainTypesRecordById , TWorldTerrainTypesParams, TWorldTerrainTypes  } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { terrainTypesAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldTerrainTypes( params: TWorldTerrainTypesParams) {
  const { mutate } = useSWR<TWorldTerrainTypes[]>(`/api/world/terrain-types/${params.id}`)
  const setWorldTerrainTypes = useSetAtom(terrainTypesAtom)
  const terrainTypes = useAtomValue(terrainTypesAtom)

  function mutateWorldTerrainTypes(optimisticParams: Partial<TWorldTerrainTypes> | Partial<TWorldTerrainTypes>[]) {
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
