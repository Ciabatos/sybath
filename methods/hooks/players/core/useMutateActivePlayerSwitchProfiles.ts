// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TActivePlayerSwitchProfilesRecordByName , TActivePlayerSwitchProfilesParams, TActivePlayerSwitchProfiles  } from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import { activePlayerSwitchProfilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateActivePlayerSwitchProfiles( params: TActivePlayerSwitchProfilesParams) {
  const { mutate } = useSWR<TActivePlayerSwitchProfiles[]>(`/api/players/rpc/get-active-player-switch-profiles/${params.playerId}`)
  const setActivePlayerSwitchProfiles = useSetAtom(activePlayerSwitchProfilesAtom)
  

  function mutateActivePlayerSwitchProfiles(optimisticParams: Partial<TActivePlayerSwitchProfiles> | Partial<TActivePlayerSwitchProfiles>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      name: ``,
      imagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["name"], dataWithDefaults) as TActivePlayerSwitchProfilesRecordByName
    
    const optimisticDataMergeWithOldData: TActivePlayerSwitchProfilesRecordByName = {
       
      ...newObj,      
    }
    
    setActivePlayerSwitchProfiles(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateActivePlayerSwitchProfiles }
}
