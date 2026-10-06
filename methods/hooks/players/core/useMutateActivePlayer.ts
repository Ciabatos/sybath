// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import { TActivePlayerParams, TActivePlayer } from "@/db/postgresMainDatabase/schemas/players/activePlayer"

export function useMutateActivePlayer(params: TActivePlayerParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/players/rpc/get-active-player`

  function mutateActivePlayer(optimisticParams?: Partial<TActivePlayer>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
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

  return { mutateActivePlayer }
}
