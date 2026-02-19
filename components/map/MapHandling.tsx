"use client"

import Map from "@/components/map/Map"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapHandlingData } from "@/methods/hooks/world/composite/useMapHandlingData"

export default function MapHandling() {
  const { combinedMap } = useMapHandlingData()
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
