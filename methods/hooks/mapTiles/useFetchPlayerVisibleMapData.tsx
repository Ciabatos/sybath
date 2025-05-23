"use client"
import { TPlayerVisibleMapData, TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { arrayToObjectKeysId } from "@/methods/functions/converters"
import { playerPositionMapTileCoordinatesAtom, playerVisibleMapDataAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export type TTileCoordinates = {
  x: number
  y: number
}
export function useFetchPlayerVisibleMapData() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setPlayerVisibleMapData = useSetAtom(playerVisibleMapDataAtom)
  const setPlayerPositionMapTile = useSetAtom(playerPositionMapTileCoordinatesAtom)
  const { data } = useSWR(`/api/map-tiles/player-visible-map-data/${playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const playerVisibleMapData = data ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", data) as TPlayerVisibleMapDataById) : {}
      setPlayerVisibleMapData(playerVisibleMapData)

      const playerPositionMapTile = data ? data.find((tile: TPlayerVisibleMapData) => tile.player_id === playerId) : null

      if (playerPositionMapTile) {
        setPlayerPositionMapTile({ x: playerPositionMapTile.map_tile_x, y: playerPositionMapTile.map_tile_y })
      } else {
        setPlayerPositionMapTile({ x: 0, y: 0 })
      }
      prevDataRef.current = data
    }
  }, [data])
}
