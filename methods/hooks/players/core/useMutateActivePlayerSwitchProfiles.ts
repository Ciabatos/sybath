// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TActivePlayerSwitchProfilesFetchParams,
  TActivePlayerSwitchProfiles,
} from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import { ACTIVEPLAYERSWITCHPROFILES_SWR_KEY } from "@/methods/hooks/players/core/useFetchActivePlayerSwitchProfiles"

export function useMutateActivePlayerSwitchProfiles(params: TActivePlayerSwitchProfilesFetchParams) {
  const { mutate } = useSWRConfig()
  const key = ACTIVEPLAYERSWITCHPROFILES_SWR_KEY(params)

  function mutateActivePlayerSwitchProfiles(optimisticParams?: Partial<TActivePlayerSwitchProfiles>[]) {
    if (!key) return

    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    /*
      Uzupełnij wartości domyślne dla `optimisticParams`. Wcześniej generator
      wpisywał tu `` (pusty string) dla KAŻDEGO pola, co dla pól liczbowych
      oznaczało `mapId: ""` — bezsensowną daną, która kompilowała się tylko
      dlatego, że `Partial<T>` maskuje typ. Uzupełniaj ręcznie albo zostaw `{}`,
      jeśli nie potrzebujesz defaults.
    */
    const defaultValues = {
      id: ``,
      name: ``,
      secondName: ``,
      nickname: ``,
      imagePortrait: ``,
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

  return { mutateActivePlayerSwitchProfiles }
}
