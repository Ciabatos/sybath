// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TSquadPlayersProfilesRecordByOtherPlayerId,
  TSquadPlayersProfiles,
  TSquadPlayersProfilesFetchParams,
} from "@/db/postgresMainDatabase/schemas/squad/squadPlayersProfiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { squadPlayersProfilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateSquadPlayersProfiles` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const SQUADPLAYERSPROFILES_SWR_KEY = (params: TSquadPlayersProfilesFetchParams) =>
  params.playerId != null ? `/api/squad/rpc/get-squad-players-profiles/${params.playerId}` : null

export function useFetchSquadPlayersProfiles(params: TSquadPlayersProfilesFetchParams) {
  const setSquadPlayersProfiles = useSetAtom(squadPlayersProfilesAtom)

  const { data } = useSWR<TSquadPlayersProfiles[]>(SQUADPLAYERSPROFILES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const squadPlayersProfiles = arrayToObjectKey(
        ["otherPlayerId"],
        data,
      ) as TSquadPlayersProfilesRecordByOtherPlayerId
      setSquadPlayersProfiles(squadPlayersProfiles)
    }
  }, [data, setSquadPlayersProfiles])
}

export function useSquadPlayersProfilesState() {
  return useAtomValue(squadPlayersProfilesAtom)
}
