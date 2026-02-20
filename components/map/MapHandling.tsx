"use client"

import Map from "@/components/map/Map"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapHandling } from "@/methods/hooks/world/composite/useMapHandling"

export default function MapHandling() {
  const { combinedMap } = useMapHandling()
  usePlayerMovement()

  return (
    <>
      {combinedMap.map(({ ...combinedMapProps }) => (
        <Map
          key={`${combinedMapProps.mapTiles.x},${combinedMapProps.mapTiles.y}`}
          {...combinedMapProps}
        />
      ))}
    </>
  )
}
