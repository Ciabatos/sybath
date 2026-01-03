import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"

type TJoinMapParams = {
  tiles: TWorldMapTilesRecordByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  cities: TCitiesCitiesRecordByMapTileXMapTileY
  districts: TDistrictsDistrictsRecordByMapTileXMapTileY
  districtTypes: TDistrictsDistrictTypesRecordById
  playerPosition: TPlayerPositionRecordByXY
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
  playerPosition?: TPlayerPositionRecordByXY[keyof TPlayerPositionRecordByXY]
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
  playerPosition,
  options = {},
}: TJoinMapParams): TJoinMapByXY {
  const { oldDataToUpdate } = options
  const mainDataEntries = Object.entries(tiles)
  const newMap: TJoinMapByXY = oldDataToUpdate ? { ...oldDataToUpdate } : {}

  // (server-side behavior, cold start)
  mainDataEntries.forEach(([key, mainDataRecord]) => {
    const joinedData = getJoinedData(
      key,
      mainDataRecord,
      terrainTypes,
      landscapeTypes,
      cities,
      districts,
      districtTypes,
      playerPosition,
    )

    const oldData = oldDataToUpdate?.[key]

    const checkChanged =
      !oldData ||
      oldData.tiles !== joinedData.newTiles ||
      oldData.terrainTypes !== joinedData.newTerrainTypes ||
      oldData.landscapeTypes !== joinedData.newLandscapeTypes ||
      oldData.cities !== joinedData.newCities ||
      oldData.districts !== joinedData.newDistricts ||
      oldData.districtTypes !== joinedData.newDistrictTypes ||
      oldData.playerPosition !== joinedData.newPlayerPosition

    if (checkChanged) {
      newMap[key] = buildNewMap(joinedData)
    }
  })

  return newMap
}

function getJoinedData(
  key: string,
  tiles: TWorldMapTilesRecordByXY[keyof TWorldMapTilesRecordByXY],
  terrainTypes: TWorldTerrainTypesRecordById,
  landscapeTypes: TWorldLandscapeTypesRecordById,
  cities: TCitiesCitiesRecordByMapTileXMapTileY,
  districts: TDistrictsDistrictsRecordByMapTileXMapTileY,
  districtTypes: TDistrictsDistrictTypesRecordById,
  playerPosition: TPlayerPositionRecordByXY,
) {
  const newTiles = tiles
  const newTerrainTypes = terrainTypes[tiles.terrainTypeId]
  const newLandscapeTypes = tiles.landscapeTypeId ? landscapeTypes[tiles.landscapeTypeId] : undefined
  const newCities = cities[key]
  const newDistricts = districts[key]
  const newDistrictTypes = newDistricts ? districtTypes[newDistricts.districtTypeId] : undefined
  const newPlayerPosition = playerPosition[key]

  return { newTiles, newTerrainTypes, newLandscapeTypes, newCities, newDistricts, newDistrictTypes, newPlayerPosition }
}

function buildNewMap(joinedData: ReturnType<typeof getJoinedData>): TJoinMap {
  return {
    tiles: joinedData.newTiles,
    terrainTypes: joinedData.newTerrainTypes,
    ...(joinedData.newLandscapeTypes && { landscapeTypes: joinedData.newLandscapeTypes }),
    ...(joinedData.newCities && { cities: joinedData.newCities }),
    ...(joinedData.newDistricts && { districts: joinedData.newDistricts }),
    ...(joinedData.newDistrictTypes && { districtTypes: joinedData.newDistrictTypes }),
    ...(joinedData.newPlayerPosition && { playerPosition: joinedData.newPlayerPosition }),
    moveCost:
      joinedData.newTerrainTypes.moveCost +
      (joinedData.newLandscapeTypes?.moveCost ?? 0) +
      (joinedData.newCities?.moveCost ?? 0),
  }
}
