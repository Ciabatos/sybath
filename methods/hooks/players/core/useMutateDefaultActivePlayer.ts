// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TDefaultActivePlayerParams,
  TDefaultActivePlayer,
} from "@/db/postgresMainDatabase/schemas/players/defaultActivePlayer"

export function useMutateDefaultActivePlayer(params: TDefaultActivePlayerParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/players/rpc/get-default-active-player`

  function mutateDefaultActivePlayer(optimisticParams?: Partial<TDefaultActivePlayer>[]) {
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

  return { mutateDefaultActivePlayer }
}
