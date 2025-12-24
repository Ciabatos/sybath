// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerMovementRecordByXY, TPlayerMovement , TPlayerMovementParams  } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerMovementAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerMovement( params: TPlayerMovementParams) {
  const playerMovement = useAtomValue(playerMovementAtom)
  const setPlayerMovement = useSetAtom(playerMovementAtom)

  const { data } = useSWR<TPlayerMovement[]>(`api/world/rpc/get-player-movement/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["x", "y"], data) as TPlayerMovementRecordByXY)
      setPlayerMovement(index)
    }
  }, [data, setPlayerMovement])
  
  return { playerMovement }
}
