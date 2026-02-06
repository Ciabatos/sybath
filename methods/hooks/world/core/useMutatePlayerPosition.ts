// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {  TPlayerPositionParams, TPlayerPosition  } from "@/db/postgresMainDatabase/schemas/world/playerPosition"


 

export function useMutatePlayerPosition( params: TPlayerPositionParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`
  

  function mutatePlayerPosition(optimisticParams?: Partial<TPlayerPosition> | Partial<TPlayerPosition>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      x: ``,
      y: ``,
      imageMap: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
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

  return { mutatePlayerPosition }
}
