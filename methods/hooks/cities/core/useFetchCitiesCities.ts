// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TCitiesCitiesRecordByMapTileXMapTileY,
  TCitiesCities,
  TCitiesCitiesParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/cities/cities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { citiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateCitiesCities` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const CITIESCITIES_SWR_KEY = () => `/api/cities/cities`

export function useFetchCitiesCities() {
  const setCitiesCities = useSetAtom(citiesAtom)

  const { data } = useSWR<TCitiesCities[]>(CITIESCITIES_SWR_KEY(), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const cities = arrayToObjectKey(["mapTileX", "mapTileY"], data) as TCitiesCitiesRecordByMapTileXMapTileY
      setCitiesCities(cities)
    }
  }, [data, setCitiesCities])
}

export function useCitiesCitiesState() {
  return useAtomValue(citiesAtom)
}
