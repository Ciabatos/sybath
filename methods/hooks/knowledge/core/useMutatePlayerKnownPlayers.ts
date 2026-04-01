// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerKnownPlayersRecordByOtherPlayerId,
  TPlayerKnownPlayersParams,
  TPlayerKnownPlayers,
} from "@/db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers"
import { playerKnownPlayersAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerKnownPlayers(params: TPlayerKnownPlayersParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/knowledge/rpc/get-player-known-players/${params.playerId}`
  const playerKnownPlayers = useAtomValue(playerKnownPlayersAtom)

  function mutatePlayerKnownPlayers(optimisticParams?: Partial<TPlayerKnownPlayers>[]) {
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
      imagePortrait: ``,
      mapId: ``,
      x: ``,
      y: ``,
      imageMap: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["otherPlayerId"], dataWithDefaults) as TPlayerKnownPlayersRecordByOtherPlayerId

    const optimisticDataMergeWithOldData: TPlayerKnownPlayersRecordByOtherPlayerId = {
      ...playerKnownPlayers,
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

  return { mutatePlayerKnownPlayers }
}
