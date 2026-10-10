// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherSquadPlayersProfilesRecordByOtherPlayerId,
  TOtherSquadPlayersProfiles,
  TOtherSquadPlayersProfilesFetchParams,
} from "@/db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherSquadPlayersProfilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateOtherSquadPlayersProfiles` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const OTHERSQUADPLAYERSPROFILES_SWR_KEY = (params: TOtherSquadPlayersProfilesFetchParams) =>
  params.playerId != null && params.squadId != null
    ? `/api/squad/rpc/get-other-squad-players-profiles/${params.playerId}/${params.squadId}`
    : null

export function useFetchOtherSquadPlayersProfiles(params: TOtherSquadPlayersProfilesFetchParams) {
  const setOtherSquadPlayersProfiles = useSetAtom(otherSquadPlayersProfilesAtom)

  const { data } = useSWR<TOtherSquadPlayersProfiles[]>(OTHERSQUADPLAYERSPROFILES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const otherSquadPlayersProfiles = arrayToObjectKey(
        ["otherPlayerId"],
        data,
      ) as TOtherSquadPlayersProfilesRecordByOtherPlayerId
      setOtherSquadPlayersProfiles(otherSquadPlayersProfiles)
    }
  }, [data, setOtherSquadPlayersProfiles])
}

export function useOtherSquadPlayersProfilesState() {
  return useAtomValue(otherSquadPlayersProfilesAtom)
}
