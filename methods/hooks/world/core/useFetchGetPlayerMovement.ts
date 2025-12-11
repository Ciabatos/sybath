// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TGetPlayerMovementRecordByXY,
  TGetPlayerMovementParams,
} from "@/db/postgresMainDatabase/schemas/world/getPlayerMovement"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerMovementAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchGetPlayerMovement(params: TGetPlayerMovementParams) {
  const getPlayerMovement = useAtomValue(getPlayerMovementAtom)
  const setGetPlayerMovement = useSetAtom(getPlayerMovementAtom)

  const { data } = useSWR(`/api/world/rpc/get-player-movement/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["x", "y"], data) as TGetPlayerMovementRecordByXY) : {}
      setGetPlayerMovement(index)
      prevDataRef.current = data
    }
  }, [data, setGetPlayerMovement])

  return { getPlayerMovement }
}
