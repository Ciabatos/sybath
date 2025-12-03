import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TPlayerVisibleMapDataRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/playerVisibleMapData"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { produce } from "immer"

export interface TJoinMap {
  tiles: TMapMapTilesRecordByXY[keyof TMapMapTilesRecordByXY]
  terrainTypes: TWorldTerrainTypesRecordById[keyof TWorldTerrainTypesRecordById]
  landscapeTypes?: TWorldLandscapeTypesRecordById[keyof TWorldLandscapeTypesRecordById]
  cities?: TMapCitiesRecordByMapTileXMapTileY[keyof TMapCitiesRecordByMapTileXMapTileY]
  districts?: TMapDistrictsRecordByMapTileXMapTileY[keyof TMapDistrictsRecordByMapTileXMapTileY]
  playerVisibleMapData?: TPlayerVisibleMapDataRecordByMapTileXMapTileY[keyof TPlayerVisibleMapDataRecordByMapTileXMapTileY]
  moveCost?: number
}

export type TJoinMapByXY = Record<string, TJoinMap>

export function joinMap(
  tiles: TMapMapTilesRecordByXY,
  terrainTypes: TWorldTerrainTypesRecordById,
  landscapeTypes: TWorldLandscapeTypesRecordById,
  cities: TMapCitiesRecordByMapTileXMapTileY,
  districts: TMapDistrictsRecordByMapTileXMapTileY,
  playerVisibleMapData: TPlayerVisibleMapDataRecordByMapTileXMapTileY,
  options: {
    oldDataToUpdate?: TJoinMapByXY
  } = {},
): TJoinMapByXY {
  const { oldDataToUpdate } = options

  function createOrUpdate(mainData: TMapMapTilesRecordByXY[keyof TWorldTerrainTypesRecordById]): TJoinMap {
    const terrainTypesData = terrainTypes[mainData.terrainTypeId]
    const landscapeTypesData = mainData.landscapeTypeId ? landscapeTypes[mainData.landscapeTypeId] : undefined
    const citiesData = cities[`${mainData.x},${mainData.y}`]
    const districtsData = districts[`${mainData.x},${mainData.y}`]
    const playerVisibleMapDataData = playerVisibleMapData[`${mainData.x},${mainData.y}`]

    return {
      tiles: mainData,
      terrainTypes: terrainTypesData,
      landscapeTypes: landscapeTypesData,
      cities: citiesData,
      districts: districtsData,
      playerVisibleMapData: playerVisibleMapDataData,
      moveCost: terrainTypesData?.moveCost + (landscapeTypesData?.moveCost ?? 0) + (citiesData?.moveCost ?? 0), //+ (districtsData?.moveCost ?? 0),
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
    return Object.fromEntries(dataEntries.map(([key, data]) => [key, createOrUpdate(data)]))
  }
}
