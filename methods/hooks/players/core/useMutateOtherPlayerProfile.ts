// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TOtherPlayerProfileFetchParams,
  TOtherPlayerProfile,
} from "@/db/postgresMainDatabase/schemas/players/otherPlayerProfile"
import { OTHERPLAYERPROFILE_SWR_KEY } from "@/methods/hooks/players/core/useFetchOtherPlayerProfile"

export function useMutateOtherPlayerProfile(params: TOtherPlayerProfileFetchParams) {
  const { mutate } = useSWRConfig()
  const key = OTHERPLAYERPROFILE_SWR_KEY(params)

  function mutateOtherPlayerProfile(optimisticParams?: Partial<TOtherPlayerProfile>[]) {
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

  return { mutateOtherPlayerProfile }
}
