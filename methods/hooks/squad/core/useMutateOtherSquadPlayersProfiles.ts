// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TOtherSquadPlayersProfilesRecordByOtherPlayerId,
  TOtherSquadPlayersProfilesParams,
  TOtherSquadPlayersProfiles,
} from "@/db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles"
import { otherSquadPlayersProfilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherSquadPlayersProfiles(params: TOtherSquadPlayersProfilesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/squad/rpc/get-other-squad-players-profiles/${params.playerId}/${params.squadId}`
  const otherSquadPlayersProfiles = useAtomValue(otherSquadPlayersProfilesAtom)

  function mutateOtherSquadPlayersProfiles(optimisticParams?: Partial<TOtherSquadPlayersProfiles>[]) {
    if (!optimisticParams) {
      mutate(key)
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

    const newObj = arrayToObjectKey(
      ["otherPlayerId"],
      dataWithDefaults,
    ) as TOtherSquadPlayersProfilesRecordByOtherPlayerId

    const optimisticDataMergeWithOldData: TOtherSquadPlayersProfilesRecordByOtherPlayerId = {
      ...otherSquadPlayersProfiles,
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

  return { mutateOtherSquadPlayersProfiles }
}
