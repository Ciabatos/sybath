// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TGetActivePlayerVisionPlayersPositionsRecordByXY, TGetActivePlayerVisionPlayersPositionsParams } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getActivePlayerVisionPlayersPositionsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchGetActivePlayerVisionPlayersPositions(params: TGetActivePlayerVisionPlayersPositionsParams) {
  const getActivePlayerVisionPlayersPositions = useAtomValue(getActivePlayerVisionPlayersPositionsAtom)
  const setGetActivePlayerVisionPlayersPositions = useSetAtom(getActivePlayerVisionPlayersPositionsAtom)

  const { data } = useSWR(`/api/world/rpc/get-active-player-vision-players-positions/${params.mapId}/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["x", "y"], data) as TGetActivePlayerVisionPlayersPositionsRecordByXY) : {}
      setGetActivePlayerVisionPlayersPositions(index)
      prevDataRef.current = data
    }
  }, [data, setGetActivePlayerVisionPlayersPositions])

  return { getActivePlayerVisionPlayersPositions }
}
