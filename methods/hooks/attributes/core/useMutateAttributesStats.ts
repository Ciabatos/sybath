// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TAttributesStatsRecordById, TAttributesStats } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { statsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesStats() {
  const { mutate } = useSWR<TAttributesStats[]>(`/api/attributes/stats`)
  const setAttributesStats = useSetAtom(statsAtom)
  

  function mutateAttributesStats(optimisticParams: Partial<TAttributesStats> | Partial<TAttributesStats>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]
    
    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAttributesStatsRecordById
    
    const optimisticDataMergeWithOldData: TAttributesStatsRecordById = {
       
      ...newObj,      
    }
    
    setAttributesStats(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateAttributesStats }
}
