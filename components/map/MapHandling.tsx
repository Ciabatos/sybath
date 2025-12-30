"use client"

import Map from "@/components/map/Map"
import { useMapHandlingData } from "@/methods/hooks/world/composite/useMapHandlingData"

export default function MapHandling() {
  const { mapTiles, cities, districts, districtTypes, playerPosition, terrainTypes, landscapeTypes } =
    useMapHandlingData()

  return (
    <>
      {Object.entries(mapTiles).map(([key, mapTiles]) => (
        <Map
          key={key}
          mapTiles={mapTiles}
          terrainTypes={terrainTypes[mapTiles.terrainTypeId]}
          landscapeTypes={mapTiles.landscapeTypeId ? landscapeTypes[mapTiles.landscapeTypeId] : undefined}
          cities={cities[`${mapTiles.x},${mapTiles.y}`]}
          districts={districts[`${mapTiles.x},${mapTiles.y}`]}
          districtTypes={
            districts[`${mapTiles.x},${mapTiles.y}`]
              ? districtTypes[districts[`${mapTiles.x},${mapTiles.y}`].districtTypeId]
              : undefined
          }
          playerPosition={playerPosition[`${mapTiles.x},${mapTiles.y}`]}
        />
      ))}
    </>
  )
}
