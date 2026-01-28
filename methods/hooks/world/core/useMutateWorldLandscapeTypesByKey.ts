// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { TWorldLandscapeTypesRecordById, TWorldLandscapeTypesParams, TWorldLandscapeTypes  } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import useSWR from "swr"
import { landscapeTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldLandscapeTypes( params: TWorldLandscapeTypesParams) {
  const { mutate } = useSWR<TWorldLandscapeTypes[]>(`/api/world/landscape-types/${params.id}`)
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
    
    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(optimisticDataMergeWithOldDataArray, {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateWorldLandscapeTypes }
}
