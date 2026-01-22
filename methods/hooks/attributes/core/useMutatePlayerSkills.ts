// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TPlayerSkillsRecordBySkillId , TPlayerSkillsParams, TPlayerSkills  } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { playerSkillsAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerSkills( params: TPlayerSkillsParams) {
  const { mutate } = useSWR<TPlayerSkills[]>(`/api/attributes/rpc/get-player-skills/${params.playerId}`)
  const setPlayerSkills = useSetAtom(playerSkillsAtom)
  const playerSkills = useAtomValue(playerSkillsAtom)

  function mutatePlayerSkills(optimisticParams?: Partial<TPlayerSkills> | Partial<TPlayerSkills>[]) {
    if (!optimisticParams) {
      mutate()
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
    
    setPlayerSkills(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerSkills }
}
