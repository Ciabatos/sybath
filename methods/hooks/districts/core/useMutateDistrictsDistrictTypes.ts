// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TDistrictsDistrictTypesRecordById, TDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { districtTypesAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateDistrictsDistrictTypes() {
  const { mutate } = useSWR<TDistrictsDistrictTypes[]>(`/api/districts/district-types`)
  const setDistrictsDistrictTypes = useSetAtom(districtTypesAtom)
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
    
    setDistrictsDistrictTypes(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateDistrictsDistrictTypes }
}
