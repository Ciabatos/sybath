// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TWorldLandscapeTypesRecordById, TWorldLandscapeTypes } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { landscapeTypesAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldLandscapeTypes() {
  const { mutate } = useSWR<TWorldLandscapeTypes[]>(`/api/world/landscape-types`)
  const setWorldLandscapeTypes = useSetAtom(landscapeTypesAtom)
  const landscapeTypes = useAtomValue(landscapeTypesAtom)

  function mutateWorldLandscapeTypes(optimisticParams?: Partial<TWorldLandscapeTypes> | Partial<TWorldLandscapeTypes>[]) {
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

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TWorldLandscapeTypesRecordById
    
    const optimisticDataMergeWithOldData: TWorldLandscapeTypesRecordById = {
      ...landscapeTypes, 
      ...newObj,      
    }
    
    setWorldLandscapeTypes(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateWorldLandscapeTypes }
}
