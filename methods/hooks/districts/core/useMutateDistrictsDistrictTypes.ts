// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TDistrictsDistrictTypesRecordById,
  TDistrictsDistrictTypes,
} from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { DISTRICTSDISTRICTTYPES_SWR_KEY } from "@/methods/hooks/districts/core/useFetchDistrictsDistrictTypes"
import { districtTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateDistrictsDistrictTypes() {
  const { mutate } = useSWRConfig()
  const key = DISTRICTSDISTRICTTYPES_SWR_KEY()
  const districtTypes = useAtomValue(districtTypesAtom)

  function mutateDistrictsDistrictTypes(optimisticParams?: Partial<TDistrictsDistrictTypes>[]) {
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

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TDistrictsDistrictTypesRecordById

    const optimisticDataMergeWithOldData: TDistrictsDistrictTypesRecordById = {
      ...districtTypes,
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

  return { mutateDistrictsDistrictTypes }
}
