// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TAttributesAbilitiesRecordById, TAttributesAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import useSWR from "swr"
import { abilitiesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesAbilities() {
  const { mutate } = useSWR<TAttributesAbilities[]>(`/api/attributes/abilities`)
  const abilities = useAtomValue(abilitiesAtom)

  function mutateAttributesAbilities(optimisticParams?: Partial<TAttributesAbilities> | Partial<TAttributesAbilities>[]) {
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

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAttributesAbilitiesRecordById
    
    const optimisticDataMergeWithOldData: TAttributesAbilitiesRecordById = {
      ...abilities,
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

  return { mutateAttributesAbilities }
}
