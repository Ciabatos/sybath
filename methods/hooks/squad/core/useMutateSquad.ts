// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import { TSquadParams, TSquad } from "@/db/postgresMainDatabase/schemas/squad/squad"

export function useMutateSquad(params: TSquadParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/squad/rpc/get-squad/${params.playerId}`

  function mutateSquad(optimisticParams?: Partial<TSquad>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      squadId: ``,
      squadName: ``,
      squadImagePortrait: ``,
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

  return { mutateSquad }
}
