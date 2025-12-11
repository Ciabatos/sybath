// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TGetPlayerVisionPlayersPositionsRecordByXY,
  TGetPlayerVisionPlayersPositionsParams,
} from "@/db/postgresMainDatabase/schemas/world/getPlayerVisionPlayersPositions"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerVisionPlayersPositionsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchGetPlayerVisionPlayersPositions(params: TGetPlayerVisionPlayersPositionsParams) {
  const getPlayerVisionPlayersPositions = useAtomValue(getPlayerVisionPlayersPositionsAtom)
  const setGetPlayerVisionPlayersPositions = useSetAtom(getPlayerVisionPlayersPositionsAtom)

  const { data } = useSWR(`/api/world/rpc/get-player-vision-players-positions/${params.mapId}/${params.playerId}`, {
    refreshInterval: 3000,
  })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["x", "y"], data) as TGetPlayerVisionPlayersPositionsRecordByXY) : {}
      setGetPlayerVisionPlayersPositions(index)
      prevDataRef.current = data
    }
  }, [data, setGetPlayerVisionPlayersPositions])

  return { getPlayerVisionPlayersPositions }
}
