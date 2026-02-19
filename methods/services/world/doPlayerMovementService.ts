// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoPlayerMovementParams, doPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/doPlayerMovement"
import { TPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { recalculatePathMoveCosts } from "@/methods/functions/map/recalculatePathMoveCosts"
import { getCitiesCitiesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCitiesByKeyServer"
import { getDistrictsDistrictsByKeyServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictsByKeyServer"
import { getDistrictsDistrictTypesServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictTypesServer"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"
import { getPlayerMapServer } from "@/methods/server-fetchers/world/core/getPlayerMapServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldMapTilesByKeyServer } from "@/methods/server-fetchers/world/core/getWorldMapTilesByKeyServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

//MANUAL CODE - START

export type TDoPlayerMovementServiceParams = {
  path: TPlayerMovementRecordByXY
  sessionUserId: number
  playerId: number
  startX: number
  startY: number
  endX: number
  endY: number
}

//MANUAL CODE - END

export async function doPlayerMovementService(params: TDoPlayerMovementServiceParams) {
  try {
    const sessionPlayerId = (await getActivePlayerServer({ userId: params.sessionUserId }, { forceFresh: true })).raw[0]
      .id
    const playerId = params.playerId

    if (sessionPlayerId !== playerId) {
      return {
        status: false,
        message: "Active player mismatch",
      }
    }

    //MANUAL CODE - START

    const mapId = (await getPlayerMapServer({ playerId })).raw[0].mapId

    const [mapTiles, terrainTypes, landscapeTypes, cities, districts, districtTypes] = await Promise.all([
      getWorldMapTilesByKeyServer({ mapId }),
      getWorldTerrainTypesServer(),
      getWorldLandscapeTypesServer(),
      getCitiesCitiesByKeyServer({ mapId }),
      getDistrictsDistrictsByKeyServer({ mapId }),
      getDistrictsDistrictTypesServer(),
    ])

    if (!mapTiles) {
      return
    }

    const path = recalculatePathMoveCosts({
      path: params.path,
      mapTiles: mapTiles.byKey,
      terrainTypes: terrainTypes.byKey,
      landscapeTypes: landscapeTypes.byKey,
      cities: cities.byKey,
      districts: districts.byKey,
      districtTypes: districtTypes.byKey,
    })

    //MANUAL CODE - END

    const data: TDoPlayerMovementParams = {
      playerId: playerId,
      path: path,
    }

    const result = await doPlayerMovement(data)
    return result
  } catch (error) {
    console.error("Error doPlayerMovementService :", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    return {
      status: false,
      message: "Unexpected error occurred. Please refresh the page.",
    }
  }
}
