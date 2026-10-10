// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId,
  TKnownMapTilesResourcesOnTileFetchParams,
  TKnownMapTilesResourcesOnTile,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnTile"
import { KNOWNMAPTILESRESOURCESONTILE_SWR_KEY } from "@/methods/hooks/world/core/useFetchKnownMapTilesResourcesOnTile"
import { knownMapTilesResourcesOnTileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateKnownMapTilesResourcesOnTile(params: TKnownMapTilesResourcesOnTileFetchParams) {
  const { mutate } = useSWRConfig()
  const key = KNOWNMAPTILESRESOURCESONTILE_SWR_KEY(params)
  const knownMapTilesResourcesOnTile = useAtomValue(knownMapTilesResourcesOnTileAtom)

  function mutateKnownMapTilesResourcesOnTile(optimisticParams?: Partial<TKnownMapTilesResourcesOnTile>[]) {
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
      mapTilesResourceId: ``,
      itemId: ``,
      quantity: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(
      ["mapTilesResourceId"],
      dataWithDefaults,
    ) as TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId

    const optimisticDataMergeWithOldData: TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId = {
      ...knownMapTilesResourcesOnTile,
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

  return { mutateKnownMapTilesResourcesOnTile }
}
