// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerCityRecordByCityId,
  TPlayerCity,
  TPlayerCityFetchParams,
} from "@/db/postgresMainDatabase/schemas/cities/playerCity"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerCityAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerCity` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERCITY_SWR_KEY = (params: TPlayerCityFetchParams) =>
  params.playerId != null ? `/api/cities/rpc/get-player-city/${params.playerId}` : null

export function useFetchPlayerCity(params: TPlayerCityFetchParams) {
  const setPlayerCity = useSetAtom(playerCityAtom)

  const { data } = useSWR<TPlayerCity[]>(PLAYERCITY_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerCity = arrayToObjectKey(["cityId"], data) as TPlayerCityRecordByCityId
      setPlayerCity(playerCity)
    }
  }, [data, setPlayerCity])
}

export function usePlayerCityState() {
  return useAtomValue(playerCityAtom)
}
