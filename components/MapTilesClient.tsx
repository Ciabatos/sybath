"use client"
import { useSession } from "next-auth/react"

import MapTile from "./MapTile"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { useJoinMapTiles } from "@/methods/hooks/useJoinMapTiles"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypesById: Record<string, TMapTerrainTypes>
}

export default function MapTilesClient({ joinedMapTiles, terrainTypesById }: Props) {
  // const session = useSession()

  const updatedTiles = useJoinMapTiles(joinedMapTiles, terrainTypesById)

  console.log(terrainTypesById, "terrainTypesById")
  return (
    <>
      {Object.entries(updatedTiles).map(([key, tile]) => (
        <MapTile
          key={key}
          tile={tile}
        />
      ))}
    </>
  )
}
