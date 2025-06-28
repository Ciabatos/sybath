"use client"

import MapTile from "@/components/map/MapTile"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useJoinMapTiles } from "@/methods/hooks/mapTiles/composite/useJoinMapTiles"

interface Props {
  joinedMapTiles: Record<string, TJoinedMapTile>
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function MapTilesHandling({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  const { joinedMapTiles: newJoinedMapTilesOnClient } = useJoinMapTiles({ joinedMapTiles, terrainTypes, landscapeTypes })

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
