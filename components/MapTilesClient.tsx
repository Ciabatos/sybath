"use client"
import type { TjoinedMapTilesObj } from "./MapTilesServer"
import MapTile from "./MapTile"

export default function MapTilesClient({ joinedMapTiles }: { joinedMapTiles: Record<string, TjoinedMapTilesObj> }) {
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
