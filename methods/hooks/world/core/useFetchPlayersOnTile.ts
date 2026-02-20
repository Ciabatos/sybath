// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayersOnTileRecordByOtherPlayerId,
  TPlayersOnTile,
  TPlayersOnTileParams,
} from "@/db/postgresMainDatabase/schemas/world/playersOnTile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playersOnTileAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayersOnTile(params: TPlayersOnTileParams) {
  const setPlayersOnTile = useSetAtom(playersOnTileAtom)

  const { data } = useSWR<TPlayersOnTile[]>(
    `/api/world/rpc/get-players-on-tile/${params.mapId}/${params.mapTileX}/${params.mapTileY}/${params.playerId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const playersOnTile = arrayToObjectKey(["otherPlayerId"], data) as TPlayersOnTileRecordByOtherPlayerId
      setPlayersOnTile(playersOnTile)
    }
  }, [data, setPlayersOnTile])
}
