// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TActivePlayerSwitchProfilesRecordById , TActivePlayerSwitchProfilesParams, TActivePlayerSwitchProfiles  } from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import { activePlayerSwitchProfilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateActivePlayerSwitchProfiles( params: TActivePlayerSwitchProfilesParams) {
  const { mutate } = useSWR<TActivePlayerSwitchProfiles[]>(`/api/players/rpc/get-active-player-switch-profiles/${params.playerId}`)
  const setActivePlayerSwitchProfiles = useSetAtom(activePlayerSwitchProfilesAtom)
  

  function mutateActivePlayerSwitchProfiles(optimisticParams?: Partial<TActivePlayerSwitchProfiles> | Partial<TActivePlayerSwitchProfiles>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      secondName: ``,
      nickname: ``,
      imagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TActivePlayerSwitchProfilesRecordById
    
    const optimisticDataMergeWithOldData: TActivePlayerSwitchProfilesRecordById = {
       
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
