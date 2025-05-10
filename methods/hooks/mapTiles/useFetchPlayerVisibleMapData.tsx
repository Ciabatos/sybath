"use client"
import { TPlayerVisibleMapData, TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { playerPositionMapTileIdAtom, playerVisibleMapDataAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerVisibleMapData() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setPlayerVisibleMapData = useSetAtom(playerVisibleMapDataAtom)
  const setPlayerPositionMapTileId = useSetAtom(playerPositionMapTileIdAtom)
  const { data, error, isLoading } = useSWR(`/api/map-tiles/player-visible-map-data/${playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    const playerVisibleMapData = data ? (arrayToObjectKeyId("map_tile_id", data) as TPlayerVisibleMapDataById) : {}
    setPlayerVisibleMapData(playerVisibleMapData)

    const playerPositionMapTileId = data ? data.find((tile: TPlayerVisibleMapData) => tile.player_id === playerId)?.map_tile_id : undefined
    setPlayerPositionMapTileId(playerPositionMapTileId)
  }, [data, error, isLoading])
}
