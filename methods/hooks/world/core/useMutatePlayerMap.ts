// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {  TPlayerMapParams, TPlayerMap  } from "@/db/postgresMainDatabase/schemas/world/playerMap"


 

export function useMutatePlayerMap( params: TPlayerMapParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-player-map/${params.playerId}`
  

  function mutatePlayerMap(optimisticParams?: Partial<TPlayerMap>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      mapId: ``,
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

  return { mutatePlayerMap }
}