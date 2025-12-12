import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerVisibleMapDataRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/playerVisibleMapData"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { produce } from "immer"

type TJoinMapParams = {
  tiles: TWorldMapTilesRecordByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  cities: TCitiesCitiesRecordByMapTileXMapTileY
  districts: TDistrictsDistrictsRecordByMapTileXMapTileY
  districtTypes: TDistrictsDistrictTypesRecordById
  playerVisibleMapData: TPlayerVisibleMapDataRecordByMapTileXMapTileY
  options: {
    oldDataToUpdate?: TJoinMapByXY
  }
}
export interface TJoinMap {
  tiles: TWorldMapTilesRecordByXY[keyof TWorldMapTilesRecordByXY]
  terrainTypes: TWorldTerrainTypesRecordById[keyof TWorldTerrainTypesRecordById]
  landscapeTypes?: TWorldLandscapeTypesRecordById[keyof TWorldLandscapeTypesRecordById]
  cities?: TCitiesCitiesRecordByMapTileXMapTileY[keyof TCitiesCitiesRecordByMapTileXMapTileY]
  districts?: TDistrictsDistrictsRecordByMapTileXMapTileY[keyof TDistrictsDistrictsRecordByMapTileXMapTileY]
  districtTypes?: TDistrictsDistrictTypesRecordById[keyof TDistrictsDistrictTypesRecordById]
  playerVisibleMapData?: TPlayerVisibleMapDataRecordByMapTileXMapTileY[keyof TPlayerVisibleMapDataRecordByMapTileXMapTileY]
  moveCost?: number
}

export type TJoinMapByXY = Record<string, TJoinMap>

export function joinMap({
  tiles,
  terrainTypes,
  landscapeTypes,
  cities,
  districts,
  districtTypes,
  playerVisibleMapData,
  options = {},
}: TJoinMapParams): TJoinMapByXY {
  const { oldDataToUpdate } = options

  function createOrUpdate(mainData: TWorldMapTilesRecordByXY[keyof TWorldMapTilesRecordByXY]): TJoinMap {
    const terrainTypesData = terrainTypes[mainData.terrainTypeId]
    const landscapeTypesData = mainData.landscapeTypeId ? landscapeTypes[mainData.landscapeTypeId] : undefined
    const citiesData = cities[`${mainData.x},${mainData.y}`]
    const districtsData = districts[`${mainData.x},${mainData.y}`]
    const districtTypesData = districtsData ? districtTypes[districtsData.districtTypeId] : undefined
    const playerVisibleMapDataData = playerVisibleMapData[`${mainData.x},${mainData.y}`]

    return {
      tiles: mainData,
      terrainTypes: terrainTypesData,
      landscapeTypes: landscapeTypesData,
      cities: citiesData,
      districts: districtsData,
      districtTypes: districtTypesData,
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
          console.log("updating tile at", createOrUpdate(data))
        }
      })
    })
  } else {
    // (server-side behavior)
    return Object.fromEntries(dataEntries.map(([key, data]) => [key, createOrUpdate(data)]))
  }
}
