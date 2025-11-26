// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerVisibleMapDataParams, TPlayerVisibleMapDataRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerVisibleMapDataAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerVisibleMapData(params: TPlayerVisibleMapDataParams) {
  const playerVisibleMapData = useAtomValue(playerVisibleMapDataAtom)
  const setPlayerVisibleMapData = useSetAtom(playerVisibleMapDataAtom)

  const { data } = useSWR(`/api/map/rpc/player-visible-map-data/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey("mapTileX", "mapTileY", data) as TPlayerVisibleMapDataRecordByMapTileXMapTileY) : {}
      setPlayerVisibleMapData(index)
      prevDataRef.current = data
    }
  }, [data, setPlayerVisibleMapData])

  return { playerVisibleMapData }
}
