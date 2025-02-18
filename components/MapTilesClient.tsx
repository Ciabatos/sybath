"use client"
import { useSession } from "next-auth/react"
import useSWR from "swr"
import MapTile from "./MapTile"
import type { TjoinedMapTile } from "@/functions/map/mapTilesServerData"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"

export default function MapTilesClient({ joinedMapTiles, terrainTypesById }: { joinedMapTiles: Record<string, TjoinedMapTile>; terrainTypesById: Record<string, TMapTerrainTypes> }) {
  const session = useSession()
  const { data, error, isLoading } = useSWR("/api/users")

  if (!session.data?.user?.email) {
    return <div>Sing In !</div>
  }
  if (isLoading) {
    return <div>Loading...</div>
  }
  if (error) {
    return <div>Error: {error.message}</div>
  }

  return (
    <>
      {Object.entries(joinedMapTiles).map(([key, tile]) => (
        <MapTile
          key={key}
          tile={tile}
        />
      ))}
    </>
  )
}
