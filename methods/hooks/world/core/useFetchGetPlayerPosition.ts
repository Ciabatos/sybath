// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TGetPlayerPositionRecordByXY,
  TGetPlayerPositionParams,
} from "@/db/postgresMainDatabase/schemas/world/getPlayerPosition"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerPositionAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchGetPlayerPosition(params: TGetPlayerPositionParams) {
  const getPlayerPosition = useAtomValue(getPlayerPositionAtom)
  const setGetPlayerPosition = useSetAtom(getPlayerPositionAtom)

  const { data } = useSWR(`/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`, {
    refreshInterval: 3000,
  })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["x", "y"], data) as TGetPlayerPositionRecordByXY) : {}
      setGetPlayerPosition(index)
      prevDataRef.current = data
    }
  }, [data, setGetPlayerPosition])

  return { getPlayerPosition }
}
