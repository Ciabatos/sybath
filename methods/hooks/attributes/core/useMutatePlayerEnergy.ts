// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerEnergyRecordByLastRegeneratedAt,
  TPlayerEnergyParams,
  TPlayerEnergy,
} from "@/db/postgresMainDatabase/schemas/attributes/playerEnergy"
import { playerEnergyAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerEnergy(params: TPlayerEnergyParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/rpc/get-player-energy/${params.playerId}`
  const playerEnergy = useAtomValue(playerEnergyAtom)

  function mutatePlayerEnergy(optimisticParams?: Partial<TPlayerEnergy>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

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
