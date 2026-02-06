// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { TDistrictsDistrictTypesRecordById, TDistrictsDistrictTypesParams, TDistrictsDistrictTypes  } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { districtTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateDistrictsDistrictTypes( params: TDistrictsDistrictTypesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/districts/district-types/${params.id}`
  const districtTypes = useAtomValue(districtTypesAtom)

  function mutateDistrictsDistrictTypes(optimisticParams?: Partial<TDistrictsDistrictTypes> | Partial<TDistrictsDistrictTypes>[]) {
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

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TDistrictsDistrictTypesRecordById
    
    const optimisticDataMergeWithOldData: TDistrictsDistrictTypesRecordById = {
      ...districtTypes,
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

  return { mutateDistrictsDistrictTypes }
}
