// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TAttributesAbilitiesRecordById, TAttributesAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { abilitiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesAbilities() {
  const { mutate } = useSWR<TAttributesAbilities[]>(`/api/attributes/abilities`)
  const setAttributesAbilities = useSetAtom(abilitiesAtom)
  

  function mutateAttributesAbilities(optimisticParams: Partial<TAttributesAbilities> | Partial<TAttributesAbilities>[]) {
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

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAttributesAbilitiesRecordById
    
    const optimisticDataMergeWithOldData: TAttributesAbilitiesRecordById = {
       
      ...newObj,      
    }
    
    setAttributesAbilities(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateAttributesAbilities }
}
