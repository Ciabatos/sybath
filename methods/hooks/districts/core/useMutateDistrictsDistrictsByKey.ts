// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TDistrictsDistrictsRecordByMapTileXMapTileY , TDistrictsDistrictsParams, TDistrictsDistricts  } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { districtsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateDistrictsDistricts( params: TDistrictsDistrictsParams) {
  const { mutate } = useSWR<TDistrictsDistricts[]>(`/api/districts/districts/${params.mapId}`)
  const setDistrictsDistricts = useSetAtom(districtsAtom)
  

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
