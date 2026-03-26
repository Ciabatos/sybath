// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TPlayerPosition, TPlayerPositionParams } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import {
  useActivePlayerProfileState,
  useFetchActivePlayerProfile,
} from "@/methods/hooks/players/core/useFetchActivePlayerProfile"
import { useSWRConfig } from "swr"

export function useMutatePlayerPosition(params: TPlayerPositionParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`

  //MANUAL CODE - START
  const { playerId } = usePlayerId()
  useFetchActivePlayerProfile({ playerId })
  const activePlayerProfile = useActivePlayerProfileState()
  const activePlayerProfileData = Object.values(activePlayerProfile)[0]
  //MANUAL CODE - END

  function mutatePlayerPosition(optimisticParams?: Partial<TPlayerPosition>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      x: ``,
      y: ``,
      imageMap: activePlayerProfileData.imageMap,
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

  return { mutatePlayerPosition }
}
