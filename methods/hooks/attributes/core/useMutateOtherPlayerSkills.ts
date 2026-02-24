// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TOtherPlayerSkillsRecordBySkillId,
  TOtherPlayerSkillsParams,
  TOtherPlayerSkills,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerSkills"
import { otherPlayerSkillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerSkills(params: TOtherPlayerSkillsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/rpc/get-other-player-skills/${params.playerId}/${params.otherPlayerId}`
  const otherPlayerSkills = useAtomValue(otherPlayerSkillsAtom)

  function mutateOtherPlayerSkills(optimisticParams?: Partial<TOtherPlayerSkills>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      skillId: ``,
      value: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["skillId"], dataWithDefaults) as TOtherPlayerSkillsRecordBySkillId

    const optimisticDataMergeWithOldData: TOtherPlayerSkillsRecordBySkillId = {
      ...otherPlayerSkills,
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

  return { mutateOtherPlayerSkills }
}
