// GENERATED CODE - DO NOT EDIT MANUALLY - hookMutateMethodFetcher.hbs
"use client"

import { TGetPlayerMovementRecordByXY, TGetPlayerMovementParams, TGetPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/getPlayerMovement"
import { getPlayerMovementAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateGetPlayerMovement(params: TGetPlayerMovementParams) {
  const { mutate } = useSWR(`/api/world/rpc/get-player-movement/${params.playerId}`)
  const setGetPlayerMovement = useSetAtom(getPlayerMovementAtom)

  function mutateGetPlayerMovement(optimisticParams: Partial<TGetPlayerMovement> | Partial<TGetPlayerMovement>[]) {
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

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TGetPlayerMovementRecordByXY

    const optimisticData: TGetPlayerMovementRecordByXY = {
      ...newObj,
    }

    setGetPlayerMovement(optimisticData)

    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateGetPlayerMovement }
}
