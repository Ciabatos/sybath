// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TOtherPlayerProfileRecordByName,
  TOtherPlayerProfileParams,
  TOtherPlayerProfile,
} from "@/db/postgresMainDatabase/schemas/players/otherPlayerProfile"
import { otherPlayerProfileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerProfile(params: TOtherPlayerProfileParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/players/rpc/get-other-player-profile/${params.playerId}/${params.otherPlayerMaskId}`
  const otherPlayerProfile = useAtomValue(otherPlayerProfileAtom)

  function mutateOtherPlayerProfile(optimisticParams?: Partial<TOtherPlayerProfile>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      name: ``,
      secondName: ``,
      nickname: ``,
      imageMap: ``,
      imagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["name"], dataWithDefaults) as TOtherPlayerProfileRecordByName

    const optimisticDataMergeWithOldData: TOtherPlayerProfileRecordByName = {
      ...otherPlayerProfile,
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

  return { mutateOtherPlayerProfile }
}
