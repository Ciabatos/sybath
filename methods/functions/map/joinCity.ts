import { TCityBuildings, TCityBuildingsByCoordinates } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { TCityTiles } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import { TMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { produce } from "immer"

export interface TJoinCity {
  tiles: TCityTiles
  terrainTypes: TMapTerrainTypesRecordById[keyof TMapTerrainTypesRecordById]
  landscapeTypes?: TMapLandscapeTypesRecordById[keyof TMapTerrainTypesRecordById]
  buildings?: TCityBuildingsRecordById[keyof TCityBuildingsRecordById]
}

export type TJoinCityByXY = Record<string, TJoinCity>

export function joinCity(
  tiles: TCityTiles[],
  terrainTypes: TMapTerrainTypesRecordById,
  landscapeTypes: TMapLandscapeTypesRecordById,
  buildings: TCityBuildingsRecordById,
  options: {
    oldDataToUpdate?: TJoinCityByXY
  } = {},
): TJoinCityByXY {
    const { oldDataToUpdate } = options

  // to jest funkcja pomocnicza dla bloku poniżej
  const createOrUpdate = (tilesData: TCityTiles): TJoinCity => {
    const terrainTypesData = terrainTypes[tilesData.terrain_type_id]
    const landscapeTypesData = tilesData.landscapeTypeId ? landscapeTypes[tilesData.landscapeTypeId] : undefined
    const buildingsData = tilesData.buildings ? buildings[`${tilesData.x},${tilesData.y}`] : undefined
    
    return {
      tiles: tilesData,
      terrainTypes: terrainTypesData,
      landscapeTypes: landscapeTypesData,
      buildings: buildingsData,
    }
  }

  const tileEntries = Object.entries(tiles)

  // To jest render block
  // (client-side behavior)
  if (oldDataToUpdate) {
    return produce(oldDataToUpdate, (draft) => {
      tileEntries.forEach(([, tile]) => {
        const key = `${tile.x},${tile.y}`
        if (draft[key]) {
          draft[key] = createOrUpdate(tile)
        }
      })
    })
  } else {
    // (server-side behavior)
    return Object.fromEntries(
      tileEntries.map(([, tile]) => {
        const key = `${tile.x},${tile.y}`
        return [key, createOrUpdate(tile)]
      }),
    )
  }
}
