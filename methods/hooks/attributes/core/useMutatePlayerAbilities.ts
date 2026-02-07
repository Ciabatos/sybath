// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TPlayerAbilitiesRecordByAbilityId,
  TPlayerAbilitiesParams,
  TPlayerAbilities,
} from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerAbilities(params: TPlayerAbilitiesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/rpc/get-player-abilities/${params.playerId}`
  const playerAbilities = useAtomValue(playerAbilitiesAtom)

  function mutatePlayerAbilities(optimisticParams?: Partial<TPlayerAbilities>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

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

    const newObj = arrayToObjectKey(["abilityId"], dataWithDefaults) as TPlayerAbilitiesRecordByAbilityId

    const optimisticDataMergeWithOldData: TPlayerAbilitiesRecordByAbilityId = {
      ...playerAbilities,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, optimisticDataMergeWithOldDataArray, {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutatePlayerAbilities }
}
