// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TBuildingsBuildingsRecordByCityTileXCityTileY,
  TBuildingsBuildings,
  TBuildingsBuildingsParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateBuildingsBuildings` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const BUILDINGSBUILDINGS_SWR_KEY_BY_KEY = (params: TBuildingsBuildingsParamsFetchParams) =>
  params.cityId != null ? `/api/buildings/buildings/${params.cityId}` : null

export function useFetchBuildingsBuildingsByKey(params: TBuildingsBuildingsParamsFetchParams) {
  const setBuildingsBuildings = useSetAtom(buildingsAtom)

  const { data } = useSWR<TBuildingsBuildings[]>(BUILDINGSBUILDINGS_SWR_KEY_BY_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const buildings = arrayToObjectKey(
        ["cityTileX", "cityTileY"],
        data,
      ) as TBuildingsBuildingsRecordByCityTileXCityTileY
      setBuildingsBuildings(buildings)
    }
  }, [data, setBuildingsBuildings])
}

export function useBuildingsBuildingsState() {
  return useAtomValue(buildingsAtom)
}
