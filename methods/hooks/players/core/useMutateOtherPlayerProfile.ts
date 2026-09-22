// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {  TOtherPlayerProfileParams, TOtherPlayerProfile  } from "@/db/postgresMainDatabase/schemas/players/otherPlayerProfile"


 

export function useMutateOtherPlayerProfile( params: TOtherPlayerProfileParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/players/rpc/get-other-player-profile/${params.playerId}/${params.otherPlayerId}`
  

  function mutateOtherPlayerProfile(optimisticParams?: Partial<TOtherPlayerProfile>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
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

    mutate(key, () => fetchFresh(key), {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateOtherPlayerProfile }
}