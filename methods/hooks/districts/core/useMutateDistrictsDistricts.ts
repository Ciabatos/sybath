// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import { TDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"

export function useMutateDistrictsDistricts() {
  const { mutate } = useSWRConfig()
  const key = `/api/districts/districts`

  function mutateDistrictsDistricts(optimisticParams?: Partial<TDistrictsDistricts>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

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

    const dataWithDefaults = optimisticParams.map((val) => ({
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
