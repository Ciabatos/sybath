// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TDistrictsDistrictTypesRecordById, TDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import useSWR from "swr"
import { districtTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateDistrictsDistrictTypes() {
  const { mutate } = useSWR<TDistrictsDistrictTypes[]>(`/api/districts/district-types`)
  const districtTypes = useAtomValue(districtTypesAtom)

  function mutateDistrictsDistrictTypes(optimisticParams?: Partial<TDistrictsDistrictTypes> | Partial<TDistrictsDistrictTypes>[]) {
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

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TDistrictsDistrictTypesRecordById
    
    const optimisticDataMergeWithOldData: TDistrictsDistrictTypesRecordById = {
      ...districtTypes,
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

  return { mutateDistrictsDistrictTypes }
}
