// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import { TPlayerPositionParams, TPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"

export function useMutatePlayerPosition(params: TPlayerPositionParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`

  function mutatePlayerPosition(optimisticParams?: Partial<TPlayerPosition>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      x: ``,
      y: ``,
      imageMap: ``,
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

  return { mutatePlayerPosition }
}
