// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { TPlayerSkillsRecordBySkillId,  TPlayerSkillsParams, TPlayerSkills  } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { playerSkillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters" 

export function useMutatePlayerSkills( params: TPlayerSkillsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/rpc/get-player-skills/${params.playerId}`
  const playerSkills = useAtomValue(playerSkillsAtom)

  function mutatePlayerSkills(optimisticParams?: Partial<TPlayerSkills> | Partial<TPlayerSkills>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      skillId: ``,
      value: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["skillId"], dataWithDefaults) as TPlayerSkillsRecordBySkillId
    
    const optimisticDataMergeWithOldData: TPlayerSkillsRecordBySkillId = {
      ...playerSkills, 
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

  return { mutatePlayerSkills }
}
