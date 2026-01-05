// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerMovementRecordByXY, TPlayerMovement , TPlayerMovementParams  } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerMovementAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerMovement( params: TPlayerMovementParams) {
  const setPlayerMovement = useSetAtom(playerMovementAtom)

  const { data } = useSWR<TPlayerMovement[]>(`/api/world/rpc/get-player-movement/${params.playerId}`, { refreshInterval: 3000 })

  const playerMovement = data
  ? (arrayToObjectKey(["x", "y"], data) as TPlayerMovementRecordByXY)
  : {}

  useEffect(() => {
    if (playerMovement) {
      setPlayerMovement(playerMovement)
    }
  }, [playerMovement, setPlayerMovement])

  return { playerMovement }
}
