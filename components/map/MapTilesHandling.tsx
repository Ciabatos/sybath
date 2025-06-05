"use client"

import MapTile from "@/components/map/MapTile"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useJoinMapTiles } from "@/methods/hooks/mapTiles/useJoinMapTiles"
import { useActionTaskInProcess } from "@/methods/hooks/tasks/useActionTaskInProcess"

interface Props {
  joinedMapTiles: Record<string, TJoinedMapTile>
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function MapTilesHandling({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  const { newJoinedMapTilesOnClient } = useJoinMapTiles({ joinedMapTiles, terrainTypes, landscapeTypes })
  useActionTaskInProcess()

  return (
    <>
      {Object.entries(newJoinedMapTilesOnClient).map(([key, tile]) => (
        <MapTile
          key={key}
          tile={tile}
        />
      ))}
    </>
  )
}
