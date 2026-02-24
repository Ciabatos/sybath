// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TOtherPlayerAbilitiesRecordByAbilityId,
  TOtherPlayerAbilitiesParams,
  TOtherPlayerAbilities,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerAbilities"
import { otherPlayerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerAbilities(params: TOtherPlayerAbilitiesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/rpc/get-other-player-abilities/${params.playerId}/${params.otherPlayerId}`
  const otherPlayerAbilities = useAtomValue(otherPlayerAbilitiesAtom)

  function mutateOtherPlayerAbilities(optimisticParams?: Partial<TOtherPlayerAbilities>[]) {
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

    const newObj = arrayToObjectKey(["abilityId"], dataWithDefaults) as TOtherPlayerAbilitiesRecordByAbilityId

    const optimisticDataMergeWithOldData: TOtherPlayerAbilitiesRecordByAbilityId = {
      ...otherPlayerAbilities,
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

  return { mutateOtherPlayerAbilities }
}
