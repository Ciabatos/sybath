// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerPositionRecordByXY,
  TPlayerPositionParams,
} from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerPositionAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerPosition(params: TPlayerPositionParams) {
  const playerPosition = useAtomValue(playerPositionAtom)
  const setPlayerPosition = useSetAtom(playerPositionAtom)

  const { data } = useSWR(`/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`, {
    refreshInterval: 3000,
  })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["x", "y"], data) as TPlayerPositionRecordByXY) : {}
      setPlayerPosition(index)
      prevDataRef.current = data
    }
  }, [data, setPlayerPosition])

  return { playerPosition }
}
