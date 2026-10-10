// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayersOnTileRecordByOtherPlayerId,
  TPlayersOnTile,
  TPlayersOnTileFetchParams,
} from "@/db/postgresMainDatabase/schemas/world/playersOnTile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playersOnTileAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayersOnTile` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERSONTILE_SWR_KEY = (params: TPlayersOnTileFetchParams) =>
  params.mapId != null && params.mapTileX != null && params.mapTileY != null && params.playerId != null
    ? `/api/world/rpc/get-players-on-tile/${params.mapId}/${params.mapTileX}/${params.mapTileY}/${params.playerId}`
    : null

export function useFetchPlayersOnTile(params: TPlayersOnTileFetchParams) {
  const setPlayersOnTile = useSetAtom(playersOnTileAtom)

  const { data } = useSWR<TPlayersOnTile[]>(PLAYERSONTILE_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playersOnTile = arrayToObjectKey(["otherPlayerId"], data) as TPlayersOnTileRecordByOtherPlayerId
      setPlayersOnTile(playersOnTile)
    }
  }, [data, setPlayersOnTile])
}

export function usePlayersOnTileState() {
  return useAtomValue(playersOnTileAtom)
}
