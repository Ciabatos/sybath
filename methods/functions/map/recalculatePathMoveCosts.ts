import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TKnownMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { calculateTileMoveCost } from "@/methods/functions/map/calculateTileMoveCost"

type TPathFromPointToPointParams = {
  path: TPlayerMovementRecordByXY
  mapTiles: TKnownMapTilesRecordByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  cities: TCitiesCitiesRecordByMapTileXMapTileY
  districts: TDistrictsDistrictsRecordByMapTileXMapTileY
  districtTypes: TDistrictsDistrictTypesRecordById
}

type TCalculatedMovement = {
  x: number
  y: number
  moveCost: number
  totalMoveCost: number
}
export function recalculatePathMoveCosts(params: TPathFromPointToPointParams): TCalculatedMovement[] {
  let totalMoveCost = 0
  const pathArray = Object.values(params.path)
  const result: TCalculatedMovement[] = []

  for (const step of pathArray) {
    let moveCost = calculateTileMoveCost(step.x, step.y, params)

    result.push({
      x: step.x,
      y: step.y,
      moveCost,
      totalMoveCost,
    })

    totalMoveCost += moveCost
  }

  return result
}
