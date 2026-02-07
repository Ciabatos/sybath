// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { TCitiesCitiesParams, TCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"

export function useMutateCitiesCities(params: TCitiesCitiesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/cities/cities/${params.mapId}`

  function mutateCitiesCities(optimisticParams?: Partial<TCitiesCities>[]) {
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
      name: ``,
      moveCost: ``,
      imageUrl: ``,
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

  return { mutateCitiesCities }
}
