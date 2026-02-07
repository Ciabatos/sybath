// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TActivePlayerSwitchProfilesParams,
  TActivePlayerSwitchProfiles,
} from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"

export function useMutateActivePlayerSwitchProfiles(params: TActivePlayerSwitchProfilesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/players/rpc/get-active-player-switch-profiles/${params.playerId}`

  function mutateActivePlayerSwitchProfiles(optimisticParams?: Partial<TActivePlayerSwitchProfiles>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      secondName: ``,
      nickname: ``,
      imagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    mutate(key, dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateActivePlayerSwitchProfiles }
}
