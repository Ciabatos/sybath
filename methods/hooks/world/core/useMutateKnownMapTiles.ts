// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TKnownMapTilesRecordByXY,
  TKnownMapTilesFetchParams,
  TKnownMapTiles,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { KNOWNMAPTILES_SWR_KEY } from "@/methods/hooks/world/core/useFetchKnownMapTiles"
import { knownMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateKnownMapTiles(params: TKnownMapTilesFetchParams) {
  const { mutate } = useSWRConfig()
  const key = KNOWNMAPTILES_SWR_KEY(params)
  const knownMapTiles = useAtomValue(knownMapTilesAtom)

  function mutateKnownMapTiles(optimisticParams?: Partial<TKnownMapTiles>[]) {
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
      mapId: ``,
      x: ``,
      y: ``,
      terrainTypeId: ``,
      landscapeTypeId: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TKnownMapTilesRecordByXY

    const optimisticDataMergeWithOldData: TKnownMapTilesRecordByXY = {
      ...knownMapTiles,
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

  return { mutateKnownMapTiles }
}
