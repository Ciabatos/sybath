import { TMapBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { TMapCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import { TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { produce } from "immer"

export interface TJoinCity {
  tiles: TMapCityTilesRecordByXY[keyof TMapTerrainTypesRecordById]
  terrainTypes: TMapTerrainTypesRecordById[keyof TMapTerrainTypesRecordById]
  landscapeTypes?: TMapLandscapeTypesRecordById[keyof TMapTerrainTypesRecordById]
  buildings?: TMapBuildingsRecordByCityTileXCityTileY[keyof TMapBuildingsRecordByCityTileXCityTileY]
}

export type TJoinCityByXY = Record<string, TJoinCity>

export function joinCity(
  tiles: TMapCityTilesRecordByXY,
  terrainTypes: TMapTerrainTypesRecordById,
  landscapeTypes: TMapLandscapeTypesRecordById,
  buildings: TMapBuildingsRecordByCityTileXCityTileY,
  options: {
    oldDataToUpdate?: TJoinCityByXY
  } = {},
): TJoinCityByXY {
  const { oldDataToUpdate } = options

  // to jest funkcja pomocnicza dla bloku poniżej
  function createOrUpdate (tilesData: TMapCityTilesRecordByXY[keyof TMapCityTilesRecordByXY]): TJoinCity {
    const terrainTypesData = terrainTypes[tilesData.terrainTypeId]
    const landscapeTypesData = tilesData.landscapeTypeId ? landscapeTypes[tilesData.landscapeTypeId] : undefined
    const buildingsData = tilesData.cityId ? buildings[`${tilesData.x},${tilesData.y}`] : undefined

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
      tileEntries.forEach(([key, tile]) => {
        if (draft[key]) {
          draft[key] = createOrUpdate(tile)
        }
      })
    })
  } else {
    // (server-side behavior)
    return Object.fromEntries(
      tileEntries.map(([key, tile]) => [key, createOrUpdate(tile)]),
    )
  }
}
