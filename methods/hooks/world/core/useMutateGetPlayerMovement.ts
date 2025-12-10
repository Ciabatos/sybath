// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TGetPlayerMovementParams, TGetPlayerMovementRecordByXY,TGetPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/getPlayerMovement"
import { getPlayerMovementAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateGetPlayerMovement(params: TGetPlayerMovementParams) {
  const { mutate } = useSWR(`/api/world/rpc/get-player-movement/${params.playerId}`)
  const setGetPlayerMovement = useSetAtom(getPlayerMovementAtom)
  const getPlayerMovement = useAtomValue(getPlayerMovementAtom)

  function mutateGetPlayerMovement(optimisticParams: Partial<TGetPlayerMovement> | Partial<TGetPlayerMovement>[]) {

    const defaultValues = {
      scheduledAt: '',
      x: '',
      y: '',
    }

    const dataWithDefaults = Object.values(optimisticParams).map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TGetPlayerMovementRecordByXY

    const optimisticData: TGetPlayerMovementRecordByXY = {
      ...getPlayerMovement, 
      ...newObj,      
    }

    setGetPlayerMovement(optimisticData)

    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateGetPlayerMovement }
}
