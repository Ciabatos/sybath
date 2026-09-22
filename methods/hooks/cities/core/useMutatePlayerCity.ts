// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import { TPlayerCityParams, TPlayerCity } from "@/db/postgresMainDatabase/schemas/cities/playerCity"

export function useMutatePlayerCity(params: TPlayerCityParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/cities/rpc/get-player-city/${params.playerId}`

  function mutatePlayerCity(optimisticParams?: Partial<TPlayerCity>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      cityId: ``,
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

  return { mutatePlayerCity }
}
