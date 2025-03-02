"use client"

import MapTile from "./MapTile"
import { useSession } from "next-auth/react"
import { useAtomValue } from "jotai"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useJoinMapTiles } from "@/methods/hooks/useJoinMapTiles"
import { useFetchMapTiles } from "@/methods/hooks/useFetchMapTiles"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapsFieldsPlayerPosition"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypesById: Record<string, TMapTerrainTypes>
  playerPositionById?: Record<string, TMapsFieldsPlayerPosition>
}

export default function MapTilesClient({ joinedMapTiles, terrainTypesById, playerPositionById }: Props) {
  const session = useSession()
  console.log(session, "Client session")

  useJoinMapTiles(joinedMapTiles, terrainTypesById, playerPositionById)
  useFetchMapTiles()

  const updatedTiles = useAtomValue(joinedMapTilesAtom)

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
