"use client"

import Map from "@/components/map/Map"
import { useMapHandlingData } from "@/methods/hooks/world/composite/useMapHandlingData"

export default function MapHandling() {
  const { mapTiles, cities, districts, districtTypes, playerPosition, terrainTypes, landscapeTypes } =
    useMapHandlingData()

  const combinedMap = Object.entries(mapTiles).map(([key, tile]) => {
    const tileKey = `${tile.x},${tile.y}`
    const district = districts[tileKey]

    return {
      key,
      mapTiles: tile,
      terrainTypes: terrainTypes[tile.terrainTypeId],
      landscapeTypes: tile.landscapeTypeId ? landscapeTypes[tile.landscapeTypeId] : undefined,
      cities: cities[tileKey],
      districts: district,
      districtTypes: district ? districtTypes[district.districtTypeId] : undefined,
      playerPosition: playerPosition[tileKey],
    }
  })

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
