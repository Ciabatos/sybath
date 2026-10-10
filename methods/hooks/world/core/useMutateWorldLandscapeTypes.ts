// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TWorldLandscapeTypesRecordById,
  TWorldLandscapeTypes,
} from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { WORLDLANDSCAPETYPES_SWR_KEY } from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import { landscapeTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldLandscapeTypes() {
  const { mutate } = useSWRConfig()
  const key = WORLDLANDSCAPETYPES_SWR_KEY()
  const landscapeTypes = useAtomValue(landscapeTypesAtom)

  function mutateWorldLandscapeTypes(optimisticParams?: Partial<TWorldLandscapeTypes>[]) {
    if (!key) return

    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    /*
      Uzupełnij wartości domyślne dla `optimisticParams`. Wcześniej generator
      wpisywał tu `` (pusty string) dla KAŻDEGO pola, co dla pól liczbowych
      oznaczało `id: ""` — bezsensowną daną, kompilującą się tylko dlatego, że
      `Partial<T>` maskuje typ. Uzupełniaj ręcznie albo zostaw `{}`.
    */
    const defaultValues = {
      id: ``,
      name: ``,
      moveCost: ``,
      imageUrl: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TWorldLandscapeTypesRecordById

    const optimisticDataMergeWithOldData: TWorldLandscapeTypesRecordById = {
      ...landscapeTypes,
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

  return { mutateWorldLandscapeTypes }
}
