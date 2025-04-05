"use client"

import MapTile from "@/components/MapTile"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useFetchMapTiles } from "@/methods/hooks/useFetchMapTiles"
import { useFetchPlayerVisibleMapData } from "@/methods/hooks/useFetchPlayerVisibleMapData"
import { useJoinMapTiles } from "@/methods/hooks/useJoinMapTiles"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { useHydrateAtoms } from "jotai/utils"
import { useSession } from "next-auth/react"

interface Props {
  joinedMapTiles: Record<string, TJoinedMapTile>
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function MapTilesClient({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  const session = useSession()
  console.log(session, "Client session")

  useHydrateAtoms([[joinedMapTilesAtom, joinedMapTiles]])

  const updatedTiles = useAtomValue(joinedMapTilesAtom)

  useFetchMapTiles()
  useFetchPlayerVisibleMapData()
  useJoinMapTiles(terrainTypes, landscapeTypes)

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
