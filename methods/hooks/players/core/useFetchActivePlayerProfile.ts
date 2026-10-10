// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TActivePlayerProfileRecordByName,
  TActivePlayerProfile,
  TActivePlayerProfileFetchParams,
} from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { activePlayerProfileAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateActivePlayerProfile` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ACTIVEPLAYERPROFILE_SWR_KEY = (params: TActivePlayerProfileFetchParams) =>
  params.playerId != null ? `/api/players/rpc/get-active-player-profile/${params.playerId}` : null

export function useFetchActivePlayerProfile(params: TActivePlayerProfileFetchParams) {
  const setActivePlayerProfile = useSetAtom(activePlayerProfileAtom)

  const { data } = useSWR<TActivePlayerProfile[]>(ACTIVEPLAYERPROFILE_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const activePlayerProfile = arrayToObjectKey(["name"], data) as TActivePlayerProfileRecordByName
      setActivePlayerProfile(activePlayerProfile)
    }
  }, [data, setActivePlayerProfile])
}

export function useActivePlayerProfileState() {
  return useAtomValue(activePlayerProfileAtom)
}
