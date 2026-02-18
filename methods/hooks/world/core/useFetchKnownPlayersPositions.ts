// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownPlayersPositionsRecordByXY,
  TKnownPlayersPositions,
  TKnownPlayersPositionsParams,
} from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownPlayersPositionsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchKnownPlayersPositions(params: TKnownPlayersPositionsParams) {
  const setKnownPlayersPositions = useSetAtom(knownPlayersPositionsAtom)

  const { data } = useSWR<TKnownPlayersPositions[]>(
    `/api/world/rpc/get-known-players-positions/${params.mapId}/${params.playerId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const knownPlayersPositions = arrayToObjectKey(["x", "y"], data) as TKnownPlayersPositionsRecordByXY
      setKnownPlayersPositions(knownPlayersPositions)
    }
  }, [data, setKnownPlayersPositions])
}
