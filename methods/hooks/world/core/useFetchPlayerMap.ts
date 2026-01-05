// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerMapRecordByMapId, TPlayerMap , TPlayerMapParams  } from "@/db/postgresMainDatabase/schemas/world/playerMap"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerMapAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerMap( params: TPlayerMapParams) {
  const setPlayerMap = useSetAtom(playerMapAtom)

  const { data } = useSWR<TPlayerMap[]>(`/api/world/rpc/get-player-map/${params.playerId}`, { refreshInterval: 3000 })

  const playerMap = data
  ? (arrayToObjectKey(["mapId"], data) as TPlayerMapRecordByMapId)
  : {}

  useEffect(() => {
    if (playerMap) {
      setPlayerMap(playerMap)
    }
  }, [playerMap, setPlayerMap])

  return { playerMap }
}
