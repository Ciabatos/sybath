// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayersOnTheSameTileRecordByOtherPlayerId,
  TPlayersOnTheSameTile,
  TPlayersOnTheSameTileParams,
} from "@/db/postgresMainDatabase/schemas/world/playersOnTheSameTile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playersOnTheSameTileAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayersOnTheSameTile(params: TPlayersOnTheSameTileParams) {
  const setPlayersOnTheSameTile = useSetAtom(playersOnTheSameTileAtom)

  const { data } = useSWR<TPlayersOnTheSameTile[]>(
    `/api/world/rpc/get-players-on-the-same-tile/${params.mapId}/${params.playerId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const playersOnTheSameTile = arrayToObjectKey(
        ["otherPlayerId"],
        data,
      ) as TPlayersOnTheSameTileRecordByOtherPlayerId
      setPlayersOnTheSameTile(playersOnTheSameTile)
    }
  }, [data, setPlayersOnTheSameTile])
}
