// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TPlayersOnTileRecordByOtherPlayerId,
  TPlayersOnTileParams,
  TPlayersOnTile,
} from "@/db/postgresMainDatabase/schemas/world/playersOnTile"
import { playersOnTileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayersOnTile(params: TPlayersOnTileParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/world/rpc/get-players-on-tile/${params.mapId}/${params.mapTileX}/${params.mapTileY}/${params.playerId}`
  const playersOnTile = useAtomValue(playersOnTileAtom)

  function mutatePlayersOnTile(optimisticParams?: Partial<TPlayersOnTile>[]) {
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
      imagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["otherPlayerId"], dataWithDefaults) as TPlayersOnTileRecordByOtherPlayerId

    const optimisticDataMergeWithOldData: TPlayersOnTileRecordByOtherPlayerId = {
      ...playersOnTile,
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

  return { mutatePlayersOnTile }
}
