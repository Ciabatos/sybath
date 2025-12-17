// GENERATED CODE - DO NOT EDIT MANUALLY - hookMutateMethodFetcher.hbs
"use client"

import {
  TPlayerPositionRecordByXY,
  TPlayerPositionParams,
  TPlayerPosition,
} from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { playerPositionAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerPosition(params: TPlayerPositionParams) {
  const { mutate } = useSWR(`/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`)
  const setPlayerPosition = useSetAtom(playerPositionAtom)

  function mutatePlayerPosition(optimisticParams: Partial<TPlayerPosition> | Partial<TPlayerPosition>[]) {
    const params = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    const defaultValues = {
      x: ``,
      y: ``,
      imageUrl: ``,
    }

    const dataWithDefaults = Object.values(params).map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TPlayerPositionRecordByXY

    const optimisticData: TPlayerPositionRecordByXY = {
      ...newObj,
    }

    setPlayerPosition(optimisticData)

    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerPosition }
}
