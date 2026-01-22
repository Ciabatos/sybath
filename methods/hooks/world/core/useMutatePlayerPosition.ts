// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TPlayerPositionRecordByXY , TPlayerPositionParams, TPlayerPosition  } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { playerPositionAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerPosition( params: TPlayerPositionParams) {
  const { mutate } = useSWR<TPlayerPosition[]>(`/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`)
  const setPlayerPosition = useSetAtom(playerPositionAtom)
  

  function mutatePlayerPosition(optimisticParams?: Partial<TPlayerPosition> | Partial<TPlayerPosition>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      x: ``,
      y: ``,
      imageMap: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["x", "y"], dataWithDefaults) as TPlayerPositionRecordByXY
    
    const optimisticDataMergeWithOldData: TPlayerPositionRecordByXY = {
       
      ...newObj,      
    }
    
    setPlayerPosition(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerPosition }
}
