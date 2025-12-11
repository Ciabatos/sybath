// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TGetActivePlayerPositionRecordByXY,
  TGetActivePlayerPositionParams,
} from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getActivePlayerPositionAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchGetActivePlayerPosition(params: TGetActivePlayerPositionParams) {
  const getActivePlayerPosition = useAtomValue(getActivePlayerPositionAtom)
  const setGetActivePlayerPosition = useSetAtom(getActivePlayerPositionAtom)

  const { data } = useSWR(`/api/world/rpc/get-active-player-position/${params.mapId}/${params.playerId}`, {
    refreshInterval: 3000,
  })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["x", "y"], data) as TGetActivePlayerPositionRecordByXY) : {}
      setGetActivePlayerPosition(index)
      prevDataRef.current = data
    }
  }, [data, setGetActivePlayerPosition])

  return { getActivePlayerPosition }
}
