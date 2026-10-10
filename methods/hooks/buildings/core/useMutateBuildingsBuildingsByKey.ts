// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TBuildingsBuildingsParamsFetchParams,
  TBuildingsBuildings,
} from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { BUILDINGSBUILDINGS_SWR_KEY_BY_KEY } from "@/methods/hooks/buildings/core/useFetchBuildingsBuildingsByKey"

export function useMutateBuildingsBuildings(params: TBuildingsBuildingsParamsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = BUILDINGSBUILDINGS_SWR_KEY_BY_KEY(params)

  function mutateBuildingsBuildings(optimisticParams?: Partial<TBuildingsBuildings>[]) {
    if (!key) return

    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    /*
      Uzupełnij wartości domyślne dla `optimisticParams`. Wcześniej generator
      wpisywał tu `` (pusty string) dla KAŻDEGO pola, co dla pól liczbowych
      oznaczało `id: ""` — bezsensowną daną, kompilującą się tylko dlatego, że
      `Partial<T>` maskuje typ. Uzupełniaj ręcznie albo zostaw `{}`.
    */
    const defaultValues = {
      id: ``,
      cityId: ``,
      cityTileX: ``,
      cityTileY: ``,
      buildingTypeId: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    mutate(key, () => fetchFresh(key), {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateBuildingsBuildings }
}
