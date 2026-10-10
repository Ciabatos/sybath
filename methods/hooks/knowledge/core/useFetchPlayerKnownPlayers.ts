// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerKnownPlayersRecordByOtherPlayerId,
  TPlayerKnownPlayers,
  TPlayerKnownPlayersFetchParams,
} from "@/db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerKnownPlayersAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerKnownPlayers` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERKNOWNPLAYERS_SWR_KEY = (params: TPlayerKnownPlayersFetchParams) =>
  params.playerId != null ? `/api/knowledge/rpc/get-player-known-players/${params.playerId}` : null

export function useFetchPlayerKnownPlayers(params: TPlayerKnownPlayersFetchParams) {
  const setPlayerKnownPlayers = useSetAtom(playerKnownPlayersAtom)

  const { data } = useSWR<TPlayerKnownPlayers[]>(PLAYERKNOWNPLAYERS_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerKnownPlayers = arrayToObjectKey(["otherPlayerId"], data) as TPlayerKnownPlayersRecordByOtherPlayerId
      setPlayerKnownPlayers(playerKnownPlayers)
    }
  }, [data, setPlayerKnownPlayers])
}

export function usePlayerKnownPlayersState() {
  return useAtomValue(playerKnownPlayersAtom)
}
