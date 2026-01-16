// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TAttributesSkillsRecordById , TAttributesSkillsParams, TAttributesSkills  } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { skillsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesSkills( params: TAttributesSkillsParams) {
  const { mutate } = useSWR<TAttributesSkills[]>(`/api/attributes/skills/${params.id}`)
  const setAttributesSkills = useSetAtom(skillsAtom)
  

  function mutateAttributesSkills(optimisticParams: Partial<TAttributesSkills> | Partial<TAttributesSkills>[]) {
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

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAttributesSkillsRecordById
    
    const optimisticDataMergeWithOldData: TAttributesSkillsRecordById = {
       
      ...newObj,      
    }
    
    setAttributesSkills(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateAttributesSkills }
}
