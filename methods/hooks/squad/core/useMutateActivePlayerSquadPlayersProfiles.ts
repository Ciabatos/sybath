// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TActivePlayerSquadPlayersProfilesRecordByName,
  TActivePlayerSquadPlayersProfilesParams,
  TActivePlayerSquadPlayersProfiles,
} from "@/db/postgresMainDatabase/schemas/squad/activePlayerSquadPlayersProfiles"
import { activePlayerSquadPlayersProfilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateActivePlayerSquadPlayersProfiles(params: TActivePlayerSquadPlayersProfilesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/squad/rpc/get-active-player-squad-players-profiles/${params.playerId}`
  const activePlayerSquadPlayersProfiles = useAtomValue(activePlayerSquadPlayersProfilesAtom)

  function mutateActivePlayerSquadPlayersProfiles(optimisticParams?: Partial<TActivePlayerSquadPlayersProfiles>[]) {
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

    const newObj = arrayToObjectKey(["name"], dataWithDefaults) as TActivePlayerSquadPlayersProfilesRecordByName

    const optimisticDataMergeWithOldData: TActivePlayerSquadPlayersProfilesRecordByName = {
      ...activePlayerSquadPlayersProfiles,
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

  return { mutateActivePlayerSquadPlayersProfiles }
}
