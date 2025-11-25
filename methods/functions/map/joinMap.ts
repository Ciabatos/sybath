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

  function createOrUpdate  (tilesData: TMapMapTilesRecordByXY[keyof TMapTerrainTypesRecordById]): TJoinMap  {
    const terrainTypesData = terrainTypes[tilesData.terrainTypeId]
    const landscapeTypesData = tilesData.landscapeTypeId ? landscapeTypes[tilesData.landscapeTypeId] : undefined
    const citiesData = cities[`${tilesData.x},${tilesData.y}`]
    const districtsData = districts[`${tilesData.x},${tilesData.y}`]
    const playerVisibleMapDataData = playerVisibleMapData[`${tilesData.x},${tilesData.y}`]

    return {
      tiles: tilesData,
      terrainTypes: terrainTypesData,
      landscapeTypes: landscapeTypesData,
      cities: citiesData,
      districts: districtsData,
      playerVisibleMapData: playerVisibleMapDataData,
      moveCost: terrainTypesData?.moveCost + (landscapeTypesData?.moveCost ?? 0) + (citiesData?.moveCost ?? 0), //+ (districtsData?.moveCost ?? 0),
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
