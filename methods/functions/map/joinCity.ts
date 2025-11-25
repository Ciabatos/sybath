import { TMapBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/map/buildings"
import { TMapCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/cityTiles"
import { TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { produce } from "immer"

export interface TJoinCity {
  tiles: TMapCityTilesRecordByXY[keyof TMapCityTilesRecordByXY]
  terrainTypes: TMapTerrainTypesRecordById[keyof TMapTerrainTypesRecordById]
  landscapeTypes?: TMapLandscapeTypesRecordById[keyof TMapLandscapeTypesRecordById]
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
  function createOrUpdate (mainData: TMapCityTilesRecordByXY[keyof TMapCityTilesRecordByXY]): TJoinCity {
    const terrainTypesData = terrainTypes[mainData.terrainTypeId]
    const landscapeTypesData = mainData.landscapeTypeId ? landscapeTypes[mainData.landscapeTypeId] : undefined
    const buildingsData = mainData.cityId ? buildings[`${mainData.x},${mainData.y}`] : undefined

    return {
      tiles: mainData,
      terrainTypes: terrainTypesData,
      landscapeTypes: landscapeTypesData,
      buildings: buildingsData,
    }
  }

  const dataEntries = Object.entries(tiles)

  // To jest render block
  // (client-side behavior)
  if (oldDataToUpdate) {
    return produce(oldDataToUpdate, (draft) => {
      dataEntries.forEach(([key, data]) => {
        if (draft[key]) {
          draft[key] = createOrUpdate(data)
        }
      })
    })
  } else {
    // (server-side behavior)
    return Object.fromEntries(
      dataEntries.map(([key, data]) => [key, createOrUpdate(data)]),
    )
  }
}
