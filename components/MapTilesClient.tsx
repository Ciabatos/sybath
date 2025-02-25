"use client"
import { useSession } from "next-auth/react"

import MapTile from "./MapTile"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesClient"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { useAtomValue } from "jotai"
import { mapTilesAtom } from "@/store/atoms"
import { joinMapTilesClient } from "@/methods/functions/joinMapTilesClient"
import { useEffect, useState } from "react"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypesById: Record<string, TMapTerrainTypes>
}

export default function MapTilesClient({ joinedMapTiles, terrainTypesById }: Props) {
  // const session = useSession()

  const [updatedTiles, setUpdatedTiles] = useState(joinedMapTiles)
  const mapTiles = useAtomValue(mapTilesAtom)

  useEffect(() => {
    if (mapTiles) {
      const updatedTiles = joinMapTilesClient(joinedMapTiles, mapTiles, terrainTypesById)
      setUpdatedTiles(updatedTiles)
    }
  }, [joinedMapTiles, mapTiles, terrainTypesById])

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
