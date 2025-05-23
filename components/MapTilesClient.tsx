"use client"

import MapTile from "@/components/MapTile"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useJoinMapTiles } from "@/methods/hooks/mapTiles/useJoinMapTiles"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

interface Props {
  joinedMapTiles: Record<string, TJoinedMapTile>
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function MapTilesClient({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  useJoinMapTiles({ joinedMapTiles, terrainTypes, landscapeTypes })

  const newJoinedMapTilesOnClient = useAtomValue(joinedMapTilesAtom)

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
