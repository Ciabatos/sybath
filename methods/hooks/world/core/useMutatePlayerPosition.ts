// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import {  TPlayerPositionParams, TPlayerPosition  } from "@/db/postgresMainDatabase/schemas/world/playerPosition"


import useSWR from "swr"
 

export function useMutatePlayerPosition( params: TPlayerPositionParams) {
  const { mutate } = useSWR<TPlayerPosition[]>(`/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`)
  

  function mutatePlayerPosition(optimisticParams?: Partial<TPlayerPosition> | Partial<TPlayerPosition>[]) {
    if (!optimisticParams) {
      mutate()
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

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutatePlayerPosition }
}
