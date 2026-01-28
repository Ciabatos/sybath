// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { TDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import useSWR from "swr"




export function useMutateDistrictsDistricts() {
  const { mutate } = useSWR<TDistrictsDistricts[]>(`/api/districts/districts`)
  

  function mutateDistrictsDistricts(optimisticParams?: Partial<TDistrictsDistricts> | Partial<TDistrictsDistricts>[]) {
    if (!optimisticParams) {
      mutate()
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

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateDistrictsDistricts }
}
