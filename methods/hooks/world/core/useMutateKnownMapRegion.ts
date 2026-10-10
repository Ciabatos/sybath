// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TKnownMapRegionRecordByMapTileXMapTileY,
  TKnownMapRegionFetchParams,
  TKnownMapRegion,
} from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { KNOWNMAPREGION_SWR_KEY } from "@/methods/hooks/world/core/useFetchKnownMapRegion"
import { knownMapRegionAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateKnownMapRegion(params: TKnownMapRegionFetchParams) {
  const { mutate } = useSWRConfig()
  const key = KNOWNMAPREGION_SWR_KEY(params)
  const knownMapRegion = useAtomValue(knownMapRegionAtom)

  function mutateKnownMapRegion(optimisticParams?: Partial<TKnownMapRegion>[]) {
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
      regionId: ``,
      mapId: ``,
      mapTileX: ``,
      mapTileY: ``,
      regionName: ``,
      imageFill: ``,
      imageOutline: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(
      ["mapTileX", "mapTileY"],
      dataWithDefaults,
    ) as TKnownMapRegionRecordByMapTileXMapTileY

    const optimisticDataMergeWithOldData: TKnownMapRegionRecordByMapTileXMapTileY = {
      ...knownMapRegion,
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

  return { mutateKnownMapRegion }
}
