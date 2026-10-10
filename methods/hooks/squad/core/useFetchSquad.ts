// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TSquadRecordBySquadId, TSquad, TSquadFetchParams } from "@/db/postgresMainDatabase/schemas/squad/squad"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { squadAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateSquad` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const SQUAD_SWR_KEY = (params: TSquadFetchParams) =>
  params.playerId != null ? `/api/squad/rpc/get-squad/${params.playerId}` : null

export function useFetchSquad(params: TSquadFetchParams) {
  const setSquad = useSetAtom(squadAtom)

  const { data } = useSWR<TSquad[]>(SQUAD_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const squad = arrayToObjectKey(["squadId"], data) as TSquadRecordBySquadId
      setSquad(squad)
    }
  }, [data, setSquad])
}

export function useSquadState() {
  return useAtomValue(squadAtom)
}
