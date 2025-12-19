// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TDistrictsDistrictsRecordByMapTileXMapTileY, TDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { districtsAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateDistrictsDistricts() {
  const { mutate } = useSWR<TDistrictsDistricts[]>(`/api/districts/districts`)
  const setDistrictsDistricts = useSetAtom(districtsAtom)
  const districts = useAtomValue(districtsAtom)

  function mutateDistrictsDistricts(optimisticParams: Partial<TDistrictsDistricts> | Partial<TDistrictsDistricts>[]) {
    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]
    
    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      mapId: ``,
      mapTileX: ``,
      mapTileY: ``,
      districtTypeId: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["mapTileX", "mapTileY"], dataWithDefaults) as TDistrictsDistrictsRecordByMapTileXMapTileY
    
    const optimisticDataMergeWithOldData: TDistrictsDistrictsRecordByMapTileXMapTileY = {
      ...districts, 
      ...newObj,      
    }
    
    setDistrictsDistricts(optimisticDataMergeWithOldData)

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutateDistrictsDistricts }
}
