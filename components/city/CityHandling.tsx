"use client"

import City from "@/components/city/City"
import { useCityHandlingData } from "@/methods/hooks/cities/composite/useCityHandlingData"

export default function CityHandling() {
  const { cityTiles, terrainTypes, landscapeTypes, buildings, buildingTypes } = useCityHandlingData()

  return (
    <>
      {Object.entries(cityTiles).map(([key, tile]) => (
        <City
          key={key}
          cityTiles={tile}
          terrainTypes={terrainTypes[tile.terrainTypeId]}
          landscapeTypes={tile.landscapeTypeId ? landscapeTypes[tile.landscapeTypeId] : undefined}
          buildings={buildings[`${tile.x},${tile.y}`]}
          buildingTypes={
            buildings[`${tile.x},${tile.y}`]
              ? buildingTypes[buildings[`${tile.x},${tile.y}`].buildingTypeId]
              : undefined
          }
        />
      ))}
    </>
  )
}
