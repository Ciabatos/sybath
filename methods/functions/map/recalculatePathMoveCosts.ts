import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TKnownMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TPlayerMovement, TPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
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

export function recalculatePathMoveCosts(params: TPathFromPointToPointParams): TPlayerMovement[] {
  let totalMoveCost = 0
  const pathArray = Object.values(params.path)
  const result: TPlayerMovement[] = []

  let blocked = false

  for (const step of pathArray) {
    let moveCost = calculateTileMoveCost(step.x, step.y, params)

    if (blocked) {
      moveCost = 9999999999
    } else if (moveCost === 0) {
      blocked = true
      moveCost = 9999999999
    }

    result.push({
      order: step.order,
      x: step.x,
      y: step.y,
      moveCost,
      totalMoveCost,
    })

    totalMoveCost += moveCost
  }

  return result
}
