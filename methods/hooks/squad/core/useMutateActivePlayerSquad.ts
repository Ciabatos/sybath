// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { TActivePlayerSquadParams, TActivePlayerSquad } from "@/db/postgresMainDatabase/schemas/squad/activePlayerSquad"

export function useMutateActivePlayerSquad(params: TActivePlayerSquadParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/squad/rpc/get-active-player-squad/${params.playerId}`

  function mutateActivePlayerSquad(optimisticParams?: Partial<TActivePlayerSquad>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      squadId: ``,
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

  return { mutateActivePlayerSquad }
}
