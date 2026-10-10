// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TOtherPlayerAbilitiesRecordByAbilityId,
  TOtherPlayerAbilitiesFetchParams,
  TOtherPlayerAbilities,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerAbilities"
import { OTHERPLAYERABILITIES_SWR_KEY } from "@/methods/hooks/attributes/core/useFetchOtherPlayerAbilities"
import { otherPlayerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerAbilities(params: TOtherPlayerAbilitiesFetchParams) {
  const { mutate } = useSWRConfig()
  const key = OTHERPLAYERABILITIES_SWR_KEY(params)
  const otherPlayerAbilities = useAtomValue(otherPlayerAbilitiesAtom)

  function mutateOtherPlayerAbilities(optimisticParams?: Partial<TOtherPlayerAbilities>[]) {
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
      abilityId: ``,
      value: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["abilityId"], dataWithDefaults) as TOtherPlayerAbilitiesRecordByAbilityId

    const optimisticDataMergeWithOldData: TOtherPlayerAbilitiesRecordByAbilityId = {
      ...otherPlayerAbilities,
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

  return { mutateOtherPlayerAbilities }
}
