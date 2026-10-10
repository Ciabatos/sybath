// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TActivePlayerRecordById,
  TActivePlayer,
  TActivePlayerFetchParams,
} from "@/db/postgresMainDatabase/schemas/players/activePlayer"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { activePlayerAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateActivePlayer` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ACTIVEPLAYER_SWR_KEY = () => `/api/players/rpc/get-active-player`

export function useFetchActivePlayer(params: TActivePlayerFetchParams) {
  const setActivePlayer = useSetAtom(activePlayerAtom)

  const { data } = useSWR<TActivePlayer[]>(ACTIVEPLAYER_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const activePlayer = arrayToObjectKey(["id"], data) as TActivePlayerRecordById
      setActivePlayer(activePlayer)
    }
  }, [data, setActivePlayer])
}

export function useActivePlayerState() {
  return useAtomValue(activePlayerAtom)
}
