import { TCitiesCitiesRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistrictsRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerVisibleMapDataRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/playerVisibleMapData"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { produce } from "immer"

export interface TJoinMap {
  tiles: TWorldMapTilesRecordByXY[keyof TWorldMapTilesRecordByXY]
  terrainTypes: TWorldTerrainTypesRecordById[keyof TWorldTerrainTypesRecordById]
  landscapeTypes?: TWorldLandscapeTypesRecordById[keyof TWorldLandscapeTypesRecordById]
  cities?: TCitiesCitiesRecordByMapIdMapTileXMapTileY[keyof TCitiesCitiesRecordByMapIdMapTileXMapTileY]
  districts?: TDistrictsDistrictsRecordByMapIdMapTileXMapTileY[keyof TDistrictsDistrictsRecordByMapIdMapTileXMapTileY]
  playerVisibleMapData?: TPlayerVisibleMapDataRecordByMapTileXMapTileY[keyof TPlayerVisibleMapDataRecordByMapTileXMapTileY]
  moveCost?: number
}

export type TJoinMapByXY = Record<string, TJoinMap>

export function joinMap(
  tiles: TWorldMapTilesRecordByXY,
  terrainTypes: TWorldTerrainTypesRecordById,
  landscapeTypes: TWorldLandscapeTypesRecordById,
  cities: TCitiesCitiesRecordByMapIdMapTileXMapTileY,
  districts: TDistrictsDistrictsRecordByMapIdMapTileXMapTileY,
  playerVisibleMapData: TPlayerVisibleMapDataRecordByMapTileXMapTileY,
  options: {
    oldDataToUpdate?: TJoinMapByXY
  } = {},
): TJoinMapByXY {
  const { oldDataToUpdate } = options

  function createOrUpdate(mainData: TWorldMapTilesRecordByXY[keyof TWorldMapTilesRecordByXY]): TJoinMap {
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
