// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TDistrictsDistrictsRecordByMapTileXMapTileY,
  TDistrictsDistricts,
  TDistrictsDistrictsParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/districts/districts"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateDistrictsDistricts` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const DISTRICTSDISTRICTS_SWR_KEY_BY_KEY = (params: TDistrictsDistrictsParamsFetchParams) =>
  params.mapId != null ? `/api/districts/districts/${params.mapId}` : null

export function useFetchDistrictsDistrictsByKey(params: TDistrictsDistrictsParamsFetchParams) {
  const setDistrictsDistricts = useSetAtom(districtsAtom)

  const { data } = useSWR<TDistrictsDistricts[]>(DISTRICTSDISTRICTS_SWR_KEY_BY_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const districts = arrayToObjectKey(["mapTileX", "mapTileY"], data) as TDistrictsDistrictsRecordByMapTileXMapTileY
      setDistrictsDistricts(districts)
    }
  }, [data, setDistrictsDistricts])
}

export function useDistrictsDistrictsState() {
  return useAtomValue(districtsAtom)
}
