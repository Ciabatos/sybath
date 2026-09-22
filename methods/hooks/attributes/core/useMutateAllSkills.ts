// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TAllSkillsRecordById,
  TAllSkillsParams,
  TAllSkills,
} from "@/db/postgresMainDatabase/schemas/attributes/allSkills"
import { allSkillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAllSkills(params: TAllSkillsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/rpc/get-all-skills/${params.playerId}`
  const allSkills = useAtomValue(allSkillsAtom)

  function mutateAllSkills(optimisticParams?: Partial<TAllSkills>[]) {
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
      value: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAllSkillsRecordById

    const optimisticDataMergeWithOldData: TAllSkillsRecordById = {
      ...allSkills,
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

  return { mutateAllSkills }
}
