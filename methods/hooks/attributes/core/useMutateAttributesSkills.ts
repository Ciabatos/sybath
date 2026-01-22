// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TAttributesSkillsRecordById, TAttributesSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { skillsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesSkills() {
  const { mutate } = useSWR<TAttributesSkills[]>(`/api/attributes/skills`)
  const setAttributesSkills = useSetAtom(skillsAtom)
  

  function mutateAttributesSkills(optimisticParams?: Partial<TAttributesSkills> | Partial<TAttributesSkills>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }
    
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
