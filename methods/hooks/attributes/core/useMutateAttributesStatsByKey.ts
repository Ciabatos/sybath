// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TAttributesStatsRecordById , TAttributesStatsParams, TAttributesStats  } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { statsAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesStats( params: TAttributesStatsParams) {
  const { mutate } = useSWR<TAttributesStats[]>(`/api/attributes/stats/${params.id}`)
  const setAttributesStats = useSetAtom(statsAtom)
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
