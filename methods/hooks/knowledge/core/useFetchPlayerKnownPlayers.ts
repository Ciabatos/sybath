// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerKnownPlayersRecordByOtherPlayerId,
  TPlayerKnownPlayers,
  TPlayerKnownPlayersParams,
} from "@/db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerKnownPlayersAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerKnownPlayers(params: TPlayerKnownPlayersParams) {
  const setPlayerKnownPlayers = useSetAtom(playerKnownPlayersAtom)

  const { data } = useSWR<TPlayerKnownPlayers[]>(`/api/knowledge/rpc/get-player-known-players/${params.playerId}`, {
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
