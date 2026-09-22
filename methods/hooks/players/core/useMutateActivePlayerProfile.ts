// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {  TActivePlayerProfileParams, TActivePlayerProfile  } from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile"


 

export function useMutateActivePlayerProfile( params: TActivePlayerProfileParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/players/rpc/get-active-player-profile/${params.playerId}`
  

  function mutateActivePlayerProfile(optimisticParams?: Partial<TActivePlayerProfile>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      name: ``,
      secondName: ``,
      nickname: ``,
      imageMap: ``,
      imagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    mutate(key, () => fetchFresh(key), {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateActivePlayerProfile }
}