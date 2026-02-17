"use client"

import Map from "@/components/map/Map"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapHandlingData } from "@/methods/hooks/world/composite/useMapHandlingData"

export default function MapHandling() {
  const { combinedMap } = useMapHandlingData()
  usePlayerMovement()

  const regionTiles = combinedMap
    .filter((t) => t.mapTiles.regionId === 1)
    .map((t) => ({
      x: t.mapTiles.x - 1,
      y: t.mapTiles.y - 1,
    }))

  console.log(regionTiles)

  return (
    <>
      {combinedMap.map(({ key, ...combinedMapProps }) => (
        <Map
          key={key}
          {...combinedMapProps}
        />
      ))}
    </>
  )
}
