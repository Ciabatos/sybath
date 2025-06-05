"use client"
import { TPlayerVisibleMapData, TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import { arrayToObjectKeysId } from "@/methods/functions/converters"
import { playerPositionMapTileAtom, playerVisibleMapDataAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerVisibleMapData() {
  const session = useSession()
  const playerId = session.data?.user.playerId

  const setPlayerVisibleMapData = useSetAtom(playerVisibleMapDataAtom)
  const setPlayerPositionMapTile = useSetAtom(playerPositionMapTileAtom)
  const { data } = useSWR(`/api/map-tiles/player-visible-map-data`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const playerVisibleMapData = data ? (arrayToObjectKeysId("map_tile_x", "map_tile_y", data) as TPlayerVisibleMapDataById) : {}
      setPlayerVisibleMapData(playerVisibleMapData)

      const playerPositionMapTile = data ? data.find((tile: TPlayerVisibleMapData) => tile.player_id === playerId) : null

      if (playerPositionMapTile) {
        setPlayerPositionMapTile(playerPositionMapTile)
      } else {
        return
      }
      prevDataRef.current = data
    }
  }, [data, playerId])
}
