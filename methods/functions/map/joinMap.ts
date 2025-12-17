import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TGetPlayerVisionPlayersPositionsRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getPlayerVisionPlayersPositions"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import equal from "fast-deep-equal"

type TJoinMapParams = {
  tiles: TWorldMapTilesRecordByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  cities: TCitiesCitiesRecordByMapTileXMapTileY
  districts: TDistrictsDistrictsRecordByMapTileXMapTileY
  districtTypes: TDistrictsDistrictTypesRecordById
  getPlayerPosition: TGetPlayerVisionPlayersPositionsRecordByXY
  options?: {
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
  getPlayerPosition?: TGetPlayerVisionPlayersPositionsRecordByXY[keyof TGetPlayerVisionPlayersPositionsRecordByXY]
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
  getPlayerPosition,
  options = {},
}: TJoinMapParams): TJoinMapByXY {
  const { oldDataToUpdate } = options

  function createOrUpdate(mainData: TWorldMapTilesRecordByXY[keyof TWorldMapTilesRecordByXY]): TJoinMap {
    const terrainTypesData = terrainTypes[mainData.terrainTypeId]
    const landscapeTypesData = mainData.landscapeTypeId ? landscapeTypes[mainData.landscapeTypeId] : undefined
    const citiesData = cities[`${mainData.x},${mainData.y}`]
    const districtsData = districts[`${mainData.x},${mainData.y}`]
    const districtTypesData = districtsData ? districtTypes[districtsData.districtTypeId] : undefined
    const getPlayerPositionData = getPlayerPosition[`${mainData.x},${mainData.y}`]

    return {
      tiles: mainData,
      terrainTypes: terrainTypesData,
      ...(landscapeTypesData && { landscapeTypes: landscapeTypesData }),
      ...(citiesData && { cities: citiesData }),
      ...(districtsData && { districts: districtsData }),
      ...(districtTypesData && { districtTypes: districtTypesData }),
      ...(getPlayerPositionData && { getPlayerPosition: getPlayerPositionData }),
      moveCost: terrainTypesData?.moveCost + (landscapeTypesData?.moveCost ?? 0) + (citiesData?.moveCost ?? 0),
    }
  }

  const dataEntries = Object.entries(tiles)

  // To jest render block
  // (client-side behavior)
  if (oldDataToUpdate) {
    const newMap = { ...oldDataToUpdate }

    dataEntries.forEach(([key, data]) => {
      const newValue = createOrUpdate(data)
      if (!equal(oldDataToUpdate[key], newValue)) {
        console.log("Updating tile at", key)
        newMap[key] = newValue
      }
    })

    return newMap
  } else {
    // (server-side behavior)
    return Object.fromEntries(dataEntries.map(([key, data]) => [key, createOrUpdate(data)]))
  }
}
