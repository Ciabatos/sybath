// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY,
  TWorldMapTilesPlayersPositionsParams,
} from "@/db/postgresMainDatabase/schemas/world/mapTilesPlayersPositions"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { mapTilesPlayersPositionsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchWorldMapTilesPlayersPositionsByKey(params: TWorldMapTilesPlayersPositionsParams) {
  const mapTilesPlayersPositions = useAtomValue(mapTilesPlayersPositionsAtom)
  const setWorldMapTilesPlayersPositions = useSetAtom(mapTilesPlayersPositionsAtom)

  const { data } = useSWR(`/api/world/map-tiles-players-positions/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data
        ? (arrayToObjectKey(["mapTileX", "mapTileY"], data) as TWorldMapTilesPlayersPositionsRecordByMapTileXMapTileY)
        : {}
      setWorldMapTilesPlayersPositions(index)
      prevDataRef.current = data
    }
  }, [data, setWorldMapTilesPlayersPositions])

  return { mapTilesPlayersPositions }
}
