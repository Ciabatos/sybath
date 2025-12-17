// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerMovementRecordByXY,
  TPlayerMovementParams,
} from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerMovementAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerMovement(params: TPlayerMovementParams) {
  const playerMovement = useAtomValue(playerMovementAtom)
  const setPlayerMovement = useSetAtom(playerMovementAtom)

  const { data } = useSWR(`/api/world/rpc/get-player-movement/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["x", "y"], data) as TPlayerMovementRecordByXY) : {}
      setPlayerMovement(index)
      prevDataRef.current = data
    }
  }, [data, setPlayerMovement])

  return { playerMovement }
}
