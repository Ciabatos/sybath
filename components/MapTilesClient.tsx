"use client"

import MapTile from "@/components/MapTile"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useMapTilesBuildOnClient } from "@/methods/hooks/mapTiles/mapTilesBuildOnClient/useMapTilesBuildOnClient"

interface Props {
  joinedMapTiles: Record<string, TJoinedMapTile>
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function MapTilesClient({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  const { newJoinedMapTilesOnClient } = useMapTilesBuildOnClient({ joinedMapTiles, terrainTypes, landscapeTypes })

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
