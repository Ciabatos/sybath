// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import {  TActivePlayerSwitchProfilesParams, TActivePlayerSwitchProfiles  } from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"


import useSWR from "swr"
 

export function useMutateActivePlayerSwitchProfiles( params: TActivePlayerSwitchProfilesParams) {
  const { mutate } = useSWR<TActivePlayerSwitchProfiles[]>(`/api/players/rpc/get-active-player-switch-profiles/${params.playerId}`)
  

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

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateActivePlayerSwitchProfiles }
}
