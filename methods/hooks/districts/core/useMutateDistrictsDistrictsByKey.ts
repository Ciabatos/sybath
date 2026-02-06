// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { TDistrictsDistrictsParams, TDistrictsDistricts  } from "@/db/postgresMainDatabase/schemas/districts/districts"




export function useMutateDistrictsDistricts( params: TDistrictsDistrictsParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/districts/districts/${params.mapId}`
  

  function mutateDistrictsDistricts(optimisticParams?: Partial<TDistrictsDistricts> | Partial<TDistrictsDistricts>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

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

    mutate(key, dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateDistrictsDistricts }
}
