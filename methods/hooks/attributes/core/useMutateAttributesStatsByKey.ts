// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TAttributesStatsRecordById,
  TAttributesStatsParams,
  TAttributesStats,
} from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { statsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesStats(params: TAttributesStatsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/stats/${params.id}`
  const stats = useAtomValue(statsAtom)

  function mutateAttributesStats(optimisticParams?: Partial<TAttributesStats>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      description: ``,
      image: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAttributesStatsRecordById

    const optimisticDataMergeWithOldData: TAttributesStatsRecordById = {
      ...stats,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, () => fetchFresh(key), {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateAttributesStats }
}
