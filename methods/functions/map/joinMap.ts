import { TMapCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/cities"
import { TMapDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/districts"
import { TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { TPlayerVisibleMapDataRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import type { TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { produce } from "immer"

export interface TJoinMap {
  mapTile: TMapMapTilesRecordByXY[keyof TMapTerrainTypesRecordById]
  terrainTypes: TMapTerrainTypesRecordById[keyof TMapTerrainTypesRecordById]
  landscapeTypes?: TMapLandscapeTypesRecordById[keyof TMapTerrainTypesRecordById]
  cities?: TMapCitiesRecordByMapTileXMapTileY[keyof TMapTerrainTypesRecordById]
  districts?: TMapDistrictsRecordByMapTileXMapTileY[keyof TMapTerrainTypesRecordById]
  playerVisibleMapData?: TPlayerVisibleMapDataRecordByMapTileXMapTileY[keyof TMapTerrainTypesRecordById]
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

  const createOrUpdateTile = (tileData: TMapMapTilesRecordByXY[keyof TMapTerrainTypesRecordById]): TJoinMap => {
    const terrainTypesData = terrainTypes[tileData.terrainTypeId]
    const landscapeTypesData = tileData.landscapeTypeId ? landscapeTypes[tileData.landscapeTypeId] : undefined
    const citiesData = cities[`${tileData.x},${tileData.y}`]
    const districtsData = districts[`${tileData.x},${tileData.y}`]
    const playerVisibleMapDataData = playerVisibleMapData[`${tileData.x},${tileData.y}`]

    return {
      mapTile: tileData,
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
      tileEntries.forEach(([, tile]) => {
        const key = `${tile.x},${tile.y}`
        if (draft[key]) {
          draft[key] = createOrUpdateTile(tile)
        }
      })
    })
  } else {
    // (server-side behavior)
    return Object.fromEntries(
      tileEntries.map(([, tile]) => {
        const key = `${tile.x},${tile.y}`
        return [key, createOrUpdateTile(tile)]
      }),
    )
  }
}
