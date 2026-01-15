// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerPositionRecordByXY, TPlayerPosition , TPlayerPositionParams  } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerPositionAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerPosition( params: TPlayerPositionParams) {
  const setPlayerPosition = useSetAtom(playerPositionAtom)

  const { data } = useSWR<TPlayerPosition[]>(`/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const playerPosition = arrayToObjectKey(["x", "y"], data) as TPlayerPositionRecordByXY
      setPlayerPosition(playerPosition)
    }
  }, [data, setPlayerPosition])
}
