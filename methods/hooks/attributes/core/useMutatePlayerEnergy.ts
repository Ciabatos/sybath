// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerEnergyRecordByLastRegeneratedAt,
  TPlayerEnergyFetchParams,
  TPlayerEnergy,
} from "@/db/postgresMainDatabase/schemas/attributes/playerEnergy"
import { PLAYERENERGY_SWR_KEY } from "@/methods/hooks/attributes/core/useFetchPlayerEnergy"
import { playerEnergyAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerEnergy(params: TPlayerEnergyFetchParams) {
  const { mutate } = useSWRConfig()
  const key = PLAYERENERGY_SWR_KEY(params)
  const playerEnergy = useAtomValue(playerEnergyAtom)

  function mutatePlayerEnergy(optimisticParams?: Partial<TPlayerEnergy>[]) {
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
      currentEnergy: ``,
      maxEnergy: ``,
      lastRegeneratedAt: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["lastRegeneratedAt"], dataWithDefaults) as TPlayerEnergyRecordByLastRegeneratedAt

    const optimisticDataMergeWithOldData: TPlayerEnergyRecordByLastRegeneratedAt = {
      ...playerEnergy,
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

  return { mutatePlayerEnergy }
}
