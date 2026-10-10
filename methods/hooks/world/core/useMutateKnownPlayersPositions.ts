// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TKnownPlayersPositionsRecordByXY,
  TKnownPlayersPositionsFetchParams,
  TKnownPlayersPositions,
} from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import { KNOWNPLAYERSPOSITIONS_SWR_KEY } from "@/methods/hooks/world/core/useFetchKnownPlayersPositions"
import { knownPlayersPositionsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateKnownPlayersPositions(params: TKnownPlayersPositionsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = KNOWNPLAYERSPOSITIONS_SWR_KEY(params)
  const knownPlayersPositions = useAtomValue(knownPlayersPositionsAtom)

  function mutateKnownPlayersPositions(optimisticParams?: Partial<TKnownPlayersPositions>[]) {
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
      x: ``,
      y: ``,
      otherPlayers: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TKnownPlayersPositionsRecordByXY

    const optimisticDataMergeWithOldData: TKnownPlayersPositionsRecordByXY = {
      ...knownPlayersPositions,
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

  return { mutateKnownPlayersPositions }
}
