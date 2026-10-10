// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TActivePlayerSwitchProfilesRecordById,
  TActivePlayerSwitchProfiles,
  TActivePlayerSwitchProfilesFetchParams,
} from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { activePlayerSwitchProfilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateActivePlayerSwitchProfiles` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ACTIVEPLAYERSWITCHPROFILES_SWR_KEY = (params: TActivePlayerSwitchProfilesFetchParams) =>
  params.playerId != null ? `/api/players/rpc/get-active-player-switch-profiles/${params.playerId}` : null

export function useFetchActivePlayerSwitchProfiles(params: TActivePlayerSwitchProfilesFetchParams) {
  const setActivePlayerSwitchProfiles = useSetAtom(activePlayerSwitchProfilesAtom)

  const { data } = useSWR<TActivePlayerSwitchProfiles[]>(ACTIVEPLAYERSWITCHPROFILES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const activePlayerSwitchProfiles = arrayToObjectKey(["id"], data) as TActivePlayerSwitchProfilesRecordById
      setActivePlayerSwitchProfiles(activePlayerSwitchProfiles)
    }
  }, [data, setActivePlayerSwitchProfiles])
}

export function useActivePlayerSwitchProfilesState() {
  return useAtomValue(activePlayerSwitchProfilesAtom)
}
