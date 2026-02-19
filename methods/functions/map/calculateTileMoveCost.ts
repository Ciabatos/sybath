import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TKnownMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"

type TTileCostContext = {
  mapTiles: TKnownMapTilesRecordByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  cities: TCitiesCitiesRecordByMapTileXMapTileY
  districts: TDistrictsDistrictsRecordByMapTileXMapTileY
  districtTypes: TDistrictsDistrictTypesRecordById
}

export function calculateTileMoveCost(x: number, y: number, ctx: TTileCostContext): number {
  const tile = ctx.mapTiles[`${x},${y}`]

  if (!tile) return 99999

  if (tile.terrainTypeId === null) return 99999

  // water
  if (tile.terrainTypeId === 8 || tile.terrainTypeId === 9) {
    return 0
  }

  let cost = 0

  if (tile.terrainTypeId !== undefined && ctx.terrainTypes[tile.terrainTypeId]) {
    cost += ctx.terrainTypes[tile.terrainTypeId].moveCost
  }

  if (tile.landscapeTypeId !== undefined && ctx.landscapeTypes[tile.landscapeTypeId]) {
    cost += ctx.landscapeTypes[tile.landscapeTypeId].moveCost
  }

  const city = ctx.cities[`${x},${y}`]
  if (city) cost += city.moveCost

  const district = ctx.districts[`${x},${y}`]
  if (district) {
    const districtType = ctx.districtTypes[district.districtTypeId]
    if (districtType) cost += districtType.moveCost
  }

  return cost
}
