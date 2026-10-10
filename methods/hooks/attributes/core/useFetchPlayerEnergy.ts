// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerEnergyRecordByLastRegeneratedAt,
  TPlayerEnergy,
  TPlayerEnergyFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerEnergy"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerEnergyAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerEnergy` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERENERGY_SWR_KEY = (params: TPlayerEnergyFetchParams) =>
  params.playerId != null ? `/api/attributes/rpc/get-player-energy/${params.playerId}` : null

export function useFetchPlayerEnergy(params: TPlayerEnergyFetchParams) {
  const setPlayerEnergy = useSetAtom(playerEnergyAtom)

  const { data } = useSWR<TPlayerEnergy[]>(PLAYERENERGY_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerEnergy = arrayToObjectKey(["lastRegeneratedAt"], data) as TPlayerEnergyRecordByLastRegeneratedAt
      setPlayerEnergy(playerEnergy)
    }
  }, [data, setPlayerEnergy])
}

export function usePlayerEnergyState() {
  return useAtomValue(playerEnergyAtom)
}
