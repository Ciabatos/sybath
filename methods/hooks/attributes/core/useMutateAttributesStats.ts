// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TAttributesStatsRecordById, TAttributesStats } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import useSWR from "swr"
import { statsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesStats() {
  const { mutate } = useSWR<TAttributesStats[]>(`/api/attributes/stats`)
  const stats = useAtomValue(statsAtom)

  function mutateAttributesStats(optimisticParams?: Partial<TAttributesStats> | Partial<TAttributesStats>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }
    
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]
    
    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      description: ``,
      image: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAttributesStatsRecordById
    
    const optimisticDataMergeWithOldData: TAttributesStatsRecordById = {
      ...stats,
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

  return { mutateAttributesStats }
}
