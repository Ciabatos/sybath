import { TMapCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/cities"
import { TMapDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/districts"
import { TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { TPlayerVisibleMapDataRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import type { TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { produce } from "immer"

export interface TJoinMap {
  tiles: TMapMapTilesRecordByXY[keyof TMapMapTilesRecordByXY]
  terrainTypes: TMapTerrainTypesRecordById[keyof TMapTerrainTypesRecordById]
  landscapeTypes?: TMapLandscapeTypesRecordById[keyof TMapLandscapeTypesRecordById]
  cities?: TMapCitiesRecordByMapTileXMapTileY[keyof TMapCitiesRecordByMapTileXMapTileY]
  districts?: TMapDistrictsRecordByMapTileXMapTileY[keyof TMapDistrictsRecordByMapTileXMapTileY]
  playerVisibleMapData?: TPlayerVisibleMapDataRecordByMapTileXMapTileY[keyof TPlayerVisibleMapDataRecordByMapTileXMapTileY]
  moveCost?: number
}

export type TJoinMapByXY = Record<string, TJoinMap>

export function joinMap(
  tiles: TMapMapTilesRecordByXY,
  terrainTypes: TMapTerrainTypesRecordById,
  landscapeTypes: TMapLandscapeTypesRecordById,
  cities: TMapCitiesRecordByMapTileXMapTileY,
  districts: TMapDistrictsRecordByMapTileXMapTileY,
  playerVisibleMapData: TPlayerVisibleMapDataRecordByMapTileXMapTileY,
  options: {
    oldDataToUpdate?: TJoinMapByXY
  } = {},
): TJoinMapByXY {
  const { oldDataToUpdate } = options

  function createOrUpdate  (mainData: TMapMapTilesRecordByXY[keyof TMapTerrainTypesRecordById]): TJoinMap  {
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
    return Object.fromEntries(
      dataEntries.map(([key, data]) => [key, createOrUpdate(data)]),
    )
  }
}
