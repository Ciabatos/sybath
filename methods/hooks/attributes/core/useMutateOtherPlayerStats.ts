// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TOtherPlayerStatsRecordByStatId,
  TOtherPlayerStatsFetchParams,
  TOtherPlayerStats,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerStats"
import { OTHERPLAYERSTATS_SWR_KEY } from "@/methods/hooks/attributes/core/useFetchOtherPlayerStats"
import { otherPlayerStatsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerStats(params: TOtherPlayerStatsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = OTHERPLAYERSTATS_SWR_KEY(params)
  const otherPlayerStats = useAtomValue(otherPlayerStatsAtom)

  function mutateOtherPlayerStats(optimisticParams?: Partial<TOtherPlayerStats>[]) {
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
      statId: ``,
      value: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["statId"], dataWithDefaults) as TOtherPlayerStatsRecordByStatId

    const optimisticDataMergeWithOldData: TOtherPlayerStatsRecordByStatId = {
      ...otherPlayerStats,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, () => fetchFresh(key), {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateOtherPlayerStats }
}
