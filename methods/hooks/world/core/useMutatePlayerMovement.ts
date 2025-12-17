// GENERATED CODE - DO NOT EDIT MANUALLY - hookMutateMethodFetcher.hbs
"use client"

import {
  TPlayerMovementRecordByXY,
  TPlayerMovementParams,
  TPlayerMovement,
} from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { playerMovementAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerMovement(params: TPlayerMovementParams) {
  const { mutate } = useSWR(`/api/world/rpc/get-player-movement/${params.playerId}`)
  const setPlayerMovement = useSetAtom(playerMovementAtom)

  function mutatePlayerMovement(optimisticParams: Partial<TPlayerMovement> | Partial<TPlayerMovement>[]) {
    const params = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    const defaultValues = {
      scheduledAt: ``,
      x: ``,
      y: ``,
    }

    const dataWithDefaults = Object.values(params).map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TPlayerMovementRecordByXY

    const optimisticData: TPlayerMovementRecordByXY = {
      ...newObj,
    }

    setPlayerMovement(optimisticData)

    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerMovement }
}
