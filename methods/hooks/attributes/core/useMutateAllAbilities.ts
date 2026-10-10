// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TAllAbilitiesRecordById,
  TAllAbilitiesFetchParams,
  TAllAbilities,
} from "@/db/postgresMainDatabase/schemas/attributes/allAbilities"
import { ALLABILITIES_SWR_KEY } from "@/methods/hooks/attributes/core/useFetchAllAbilities"
import { allAbilitiesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAllAbilities(params: TAllAbilitiesFetchParams) {
  const { mutate } = useSWRConfig()
  const key = ALLABILITIES_SWR_KEY(params)
  const allAbilities = useAtomValue(allAbilitiesAtom)

  function mutateAllAbilities(optimisticParams?: Partial<TAllAbilities>[]) {
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
      description: ``,
      image: ``,
      value: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAllAbilitiesRecordById

    const optimisticDataMergeWithOldData: TAllAbilitiesRecordById = {
      ...allAbilities,
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

  return { mutateAllAbilities }
}
