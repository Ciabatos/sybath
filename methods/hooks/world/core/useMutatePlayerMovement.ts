// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TPlayerMovement, TPlayerMovementParams } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { useSWRConfig } from "swr"

export function useMutatePlayerMovement(params: TPlayerMovementParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-player-movement/${params.playerId}`

  function mutatePlayerMovement(optimisticParams?: Partial<TPlayerMovement>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      moveCost: 0,
      x: 0,
      y: 0,
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

  return { mutatePlayerMovement }
}
