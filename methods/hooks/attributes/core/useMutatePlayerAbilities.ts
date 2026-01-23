// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TPlayerAbilitiesRecordByAbilityId , TPlayerAbilitiesParams, TPlayerAbilities  } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerAbilities( params: TPlayerAbilitiesParams) {
  const { mutate } = useSWR<TPlayerAbilities[]>(`/api/attributes/rpc/get-player-abilities/${params.playerId}`)
  const setPlayerAbilities = useSetAtom(playerAbilitiesAtom)
  const playerAbilities = useAtomValue(playerAbilitiesAtom)

  function mutatePlayerAbilities(optimisticParams?: Partial<TPlayerAbilities> | Partial<TPlayerAbilities>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      abilityId: ``,
      value: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["abilityId"], dataWithDefaults) as TPlayerAbilitiesRecordByAbilityId
    
    const optimisticDataMergeWithOldData: TPlayerAbilitiesRecordByAbilityId = {
      ...playerAbilities, 
      ...newObj,      
    }
    
    setPlayerAbilities(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerAbilities }
}
