// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TCitiesCityTilesRecordByXY,
  TCitiesCityTiles,
  TCitiesCityTilesParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { cityTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateCitiesCityTiles` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const CITIESCITYTILES_SWR_KEY = () => `/api/cities/city-tiles`

export function useFetchCitiesCityTiles() {
  const setCitiesCityTiles = useSetAtom(cityTilesAtom)

  const { data } = useSWR<TCitiesCityTiles[]>(CITIESCITYTILES_SWR_KEY(), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const cityTiles = arrayToObjectKey(["x", "y"], data) as TCitiesCityTilesRecordByXY
      setCitiesCityTiles(cityTiles)
    }
  }, [data, setCitiesCityTiles])
}

export function useCitiesCityTilesState() {
  return useAtomValue(cityTilesAtom)
}
