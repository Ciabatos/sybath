"use client"

import MapTile from "@/components/map/MapTile"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapHandling } from "@/methods/hooks/world/composite/useMapHandling"

export default function MapHandling() {
  const { combinedMap } = useMapHandling()
  usePlayerMovement()

  return (
    <>
      {combinedMap.map(({ ...combinedMapProps }) => (
        <MapTile
          key={`${combinedMapProps.mapTiles.x},${combinedMapProps.mapTiles.y}`}
          {...combinedMapProps}
        />
      ))}
    </>
  )
}
