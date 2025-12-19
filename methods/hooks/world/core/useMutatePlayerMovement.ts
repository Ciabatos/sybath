// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TPlayerMovementRecordByXY , TPlayerMovementParams, TPlayerMovement  } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { playerMovementAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerMovement( params: TPlayerMovementParams) {
  const { mutate } = useSWR<TPlayerMovement[]>(`/api/world/rpc/get-player-movement/${params.playerId}`)
  const setPlayerMovement = useSetAtom(playerMovementAtom)
  

  function mutatePlayerMovement(optimisticParams: Partial<TPlayerMovement> | Partial<TPlayerMovement>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      scheduledAt: ``,
      x: ``,
      y: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TPlayerMovementRecordByXY
    
    const optimisticDataMergeWithOldData: TPlayerMovementRecordByXY = {
       
      ...newObj,      
    }
    
    setPlayerMovement(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerMovement }
}
