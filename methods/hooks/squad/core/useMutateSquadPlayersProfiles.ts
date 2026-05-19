// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TSquadPlayersProfilesRecordByOtherPlayerId,
  TSquadPlayersProfilesParams,
  TSquadPlayersProfiles,
} from "@/db/postgresMainDatabase/schemas/squad/squadPlayersProfiles"
import { squadPlayersProfilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateSquadPlayersProfiles(params: TSquadPlayersProfilesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/squad/rpc/get-squad-players-profiles/${params.playerId}`
  const squadPlayersProfiles = useAtomValue(squadPlayersProfilesAtom)

  function mutateSquadPlayersProfiles(optimisticParams?: Partial<TSquadPlayersProfiles>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      otherPlayerId: ``,
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

    const newObj = arrayToObjectKey(["otherPlayerId"], dataWithDefaults) as TSquadPlayersProfilesRecordByOtherPlayerId

    const optimisticDataMergeWithOldData: TSquadPlayersProfilesRecordByOtherPlayerId = {
      ...squadPlayersProfiles,
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

  return { mutateSquadPlayersProfiles }
}
