// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY,
  TKnownMapTilesResourcesOnMapFetchParams,
  TKnownMapTilesResourcesOnMap,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap"
import { KNOWNMAPTILESRESOURCESONMAP_SWR_KEY } from "@/methods/hooks/world/core/useFetchKnownMapTilesResourcesOnMap"
import { knownMapTilesResourcesOnMapAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateKnownMapTilesResourcesOnMap(params: TKnownMapTilesResourcesOnMapFetchParams) {
  const { mutate } = useSWRConfig()
  const key = KNOWNMAPTILESRESOURCESONMAP_SWR_KEY(params)
  const knownMapTilesResourcesOnMap = useAtomValue(knownMapTilesResourcesOnMapAtom)

  function mutateKnownMapTilesResourcesOnMap(optimisticParams?: Partial<TKnownMapTilesResourcesOnMap>[]) {
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
      mapTileX: ``,
      mapTileY: ``,
      itemIds: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(
      ["mapTileX", "mapTileY"],
      dataWithDefaults,
    ) as TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY

    const optimisticDataMergeWithOldData: TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY = {
      ...knownMapTilesResourcesOnMap,
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

  return { mutateKnownMapTilesResourcesOnMap }
}
