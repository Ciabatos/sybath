// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TActivePlayerProfileRecordByName , TActivePlayerProfileParams, TActivePlayerProfile  } from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile"
import { activePlayerProfileAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateActivePlayerProfile( params: TActivePlayerProfileParams) {
  const { mutate } = useSWR<TActivePlayerProfile[]>(`/api/players/rpc/get-active-player-profile/${params.playerId}`)
  const setActivePlayerProfile = useSetAtom(activePlayerProfileAtom)
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
    
    setActivePlayerProfile(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateActivePlayerProfile }
}
