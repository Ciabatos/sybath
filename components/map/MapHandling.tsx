"use client"

import Map from "@/components/map/Map"
import { useMapHandlingData } from "@/methods/hooks/world/composite/useMapHandlingData"

export default function MapHandling() {
  const { mapTiles, cities, districts, districtTypes, playerPosition, terrainTypes, landscapeTypes } =
    useMapHandlingData()

  return (
    <>
      {Object.entries(mapTiles).map(([key, tile]) => (
        <Map
          key={key}
          mapTiles={tile}
          terrainTypes={terrainTypes[tile.terrainTypeId]}
          landscapeTypes={tile.landscapeTypeId ? landscapeTypes[tile.landscapeTypeId] : undefined}
          cities={cities[`${tile.x},${tile.y}`]}
          districts={districts[`${tile.x},${tile.y}`]}
          districtTypes={
            districts[`${tile.x},${tile.y}`]
              ? districtTypes[districts[`${tile.x},${tile.y}`].districtTypeId]
              : undefined
          }
          playerPosition={playerPosition[`${tile.x},${tile.y}`]}
        />
      ))}
    </>
  )
}
