"use client"
import { TPlayerVisibleMapData } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { arrayToObjectKeyId } from "@/methods/functions/converters"
import { playerVisibleMapDataAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerVisibleMapData() {
  const session = useSession()
  const playerId = session?.data?.user.playerId

  const setPlayerVisibleMapData = useSetAtom(playerVisibleMapDataAtom)
  const { data, error, isLoading } = useSWR(`/api/map-tiles-players-positions/${playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    const playerVisibleMapData = data ? (arrayToObjectKeyId("map_tile_id", data) as Record<number, TPlayerVisibleMapData>) : {}
    setPlayerVisibleMapData(playerVisibleMapData)
  }, [data, error, isLoading])
}
