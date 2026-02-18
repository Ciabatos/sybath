// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TPlayersOnTheSameTileRecordByOtherPlayerId,
  TPlayersOnTheSameTileParams,
  TPlayersOnTheSameTile,
} from "@/db/postgresMainDatabase/schemas/world/playersOnTheSameTile"
import { playersOnTheSameTileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayersOnTheSameTile(params: TPlayersOnTheSameTileParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-players-on-the-same-tile/${params.mapId}/${params.playerId}`
  const playersOnTheSameTile = useAtomValue(playersOnTheSameTileAtom)

  function mutatePlayersOnTheSameTile(optimisticParams?: Partial<TPlayersOnTheSameTile>[]) {
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

    const newObj = arrayToObjectKey(["otherPlayerId"], dataWithDefaults) as TPlayersOnTheSameTileRecordByOtherPlayerId

    const optimisticDataMergeWithOldData: TPlayersOnTheSameTileRecordByOtherPlayerId = {
      ...playersOnTheSameTile,
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

  return { mutatePlayersOnTheSameTile }
}
