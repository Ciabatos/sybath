// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TActivePlayer } from "@/db/postgresMainDatabase/schemas/players/activePlayer"
import useSWR from "swr"

export function useMutateActivePlayer() {
  const { mutate } = useSWR<TActivePlayer[]>(`/api/players/rpc/get-active-player`)

  function mutateActivePlayer(optimisticParams?: Partial<TActivePlayer>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      id: 0,
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

  return { mutateActivePlayer }
}
