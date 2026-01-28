// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TActivePlayerProfileRecordByName,  TActivePlayerProfileParams, TActivePlayerProfile  } from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile"
import { activePlayerProfileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters" 

export function useMutateActivePlayerProfile( params: TActivePlayerProfileParams) {
  const { mutate } = useSWR<TActivePlayerProfile[]>(`/api/players/rpc/get-active-player-profile/${params.playerId}`)
  const activePlayerProfile = useAtomValue(activePlayerProfileAtom)

  function mutateActivePlayerProfile(optimisticParams?: Partial<TActivePlayerProfile> | Partial<TActivePlayerProfile>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      name: ``,
      secondName: ``,
      nickname: ``,
      imageMap: ``,
      imagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["name"], dataWithDefaults) as TActivePlayerProfileRecordByName
    
    const optimisticDataMergeWithOldData: TActivePlayerProfileRecordByName = {
      ...activePlayerProfile, 
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

  return { mutateActivePlayerProfile }
}
