// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerProfileRecordByName,
  TOtherPlayerProfile,
  TOtherPlayerProfileFetchParams,
} from "@/db/postgresMainDatabase/schemas/players/otherPlayerProfile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerProfileAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateOtherPlayerProfile` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const OTHERPLAYERPROFILE_SWR_KEY = (params: TOtherPlayerProfileFetchParams) =>
  params.playerId != null && params.otherPlayerId != null
    ? `/api/players/rpc/get-other-player-profile/${params.playerId}/${params.otherPlayerId}`
    : null

export function useFetchOtherPlayerProfile(params: TOtherPlayerProfileFetchParams) {
  const setOtherPlayerProfile = useSetAtom(otherPlayerProfileAtom)

  const { data } = useSWR<TOtherPlayerProfile[]>(OTHERPLAYERPROFILE_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const otherPlayerProfile = arrayToObjectKey(["name"], data) as TOtherPlayerProfileRecordByName
      setOtherPlayerProfile(otherPlayerProfile)
    }
  }, [data, setOtherPlayerProfile])
}

export function useOtherPlayerProfileState() {
  return useAtomValue(otherPlayerProfileAtom)
}
