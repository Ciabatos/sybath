// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TActivePlayerRecordById , TActivePlayerParams, TActivePlayer  } from "@/db/postgresMainDatabase/schemas/players/activePlayer"
import { activePlayerAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateActivePlayer( params: TActivePlayerParams) {
  const { mutate } = useSWR<TActivePlayer[]>(`/api/players/rpc/get-active-player/${params.playerId}`)
  const setActivePlayer = useSetAtom(activePlayerAtom)
  

  function mutateActivePlayer(optimisticParams: Partial<TActivePlayer> | Partial<TActivePlayer>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      imageMap: ``,
      imagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TActivePlayerRecordById
    
    const optimisticDataMergeWithOldData: TActivePlayerRecordById = {
       
      ...newObj,      
    }
    
    setActivePlayer(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateActivePlayer }
}
