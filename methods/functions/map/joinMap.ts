import { TCitiesCities, TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import {
  TDistrictsDistricts,
  TDistrictsDistrictsRecordByMapTileXMapTileY,
} from "@/db/postgresMainDatabase/schemas/districts/districts"
import {
  TDistrictsDistrictTypes,
  TDistrictsDistrictTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import {
  TWorldLandscapeTypes,
  TWorldLandscapeTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerPosition, TPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TWorldTerrainTypes, TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"

type TJoinMapParams = {
  mapTiles: TWorldMapTilesRecordByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  cities: TCitiesCitiesRecordByMapTileXMapTileY
  districts: TDistrictsDistrictsRecordByMapTileXMapTileY
  districtTypes: TDistrictsDistrictTypesRecordById
  playerPosition: TPlayerPositionRecordByXY
}
export interface TJoinMap {
  mapTiles: TWorldMapTiles
  terrainTypes: TWorldTerrainTypes
  landscapeTypes?: TWorldLandscapeTypes
  cities?: TCitiesCities
  districts?: TDistrictsDistricts
  districtTypes?: TDistrictsDistrictTypes
  playerPosition?: TPlayerPosition
  moveCost?: number
}

export function joinMap({
  mapTiles,
  terrainTypes,
  landscapeTypes,
  cities,
  districts,
  districtTypes,
  playerPosition,
}: TJoinMapParams): TJoinMap[] {
  return Object.entries(mapTiles).map(([key, mapTiles]) => {
    const xyKey = `${mapTiles.x},${mapTiles.y}`

    return {
      mapTiles,
      terrainTypes: terrainTypes[mapTiles.terrainTypeId],
      landscapeTypes: mapTiles.landscapeTypeId ? landscapeTypes[mapTiles.landscapeTypeId] : undefined,
      cities: cities[xyKey],
      districts: districts[xyKey],
      districtTypes: districts[xyKey] ? districtTypes[districts[xyKey].districtTypeId] : undefined,
      playerPosition: playerPosition[xyKey],
    }
  })
}
