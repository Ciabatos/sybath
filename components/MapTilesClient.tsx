"use client"

import MapTile from "./MapTile"
// import { useSession } from "next-auth/react"
import { useAtomValue } from "jotai"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useJoinMapTiles } from "@/methods/hooks/useJoinMapTiles"
import { useFetchMapTiles } from "@/methods/hooks/useFetchMapTiles"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypesById: Record<string, TMapTerrainTypes>
}

export default function MapTilesClient({ joinedMapTiles, terrainTypesById }: Props) {
  // const session = useSession()
  useJoinMapTiles(joinedMapTiles, terrainTypesById)
  useFetchMapTiles()

  const updatedTiles = useAtomValue(joinedMapTilesAtom)
  console.log(updatedTiles, "updatedTiles")
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
