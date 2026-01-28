// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TAttributesSkillsRecordById, TAttributesSkills } from "@/db/postgresMainDatabase/schemas/attributes/skills"
import useSWR from "swr"
import { skillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesSkills() {
  const { mutate } = useSWR<TAttributesSkills[]>(`/api/attributes/skills`)
  const skills = useAtomValue(skillsAtom)

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
      description: ``,
      image: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAttributesSkillsRecordById
    
    const optimisticDataMergeWithOldData: TAttributesSkillsRecordById = {
      ...skills,
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

  return { mutateAttributesSkills }
}
