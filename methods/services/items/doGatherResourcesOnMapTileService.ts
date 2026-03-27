// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import {
  TDoGatherResourcesOnMapTileParams,
  doGatherResourcesOnMapTile,
} from "@/db/postgresMainDatabase/schemas/items/doGatherResourcesOnMapTile"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"
import { getPlayerMapServer } from "@/methods/server-fetchers/world/core/getPlayerMapServer"
import { getPlayerPositionServer } from "@/methods/server-fetchers/world/core/getPlayerPositionServer"

//MANUAL CODE - START

export type TDoGatherResourcesOnMapTileServiceParams = {
  sessionUserId: number
  playerId: number
  mapId: number
  targetTileX: number
  targetTileY: number
  mapTilesResourceId: number
  gatherAmount: number
}

//MANUAL CODE - END

export async function doGatherResourcesOnMapTileService(params: TDoGatherResourcesOnMapTileServiceParams) {
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

    const [playerPosition] = await Promise.all([getPlayerPositionServer({ mapId, playerId }, { forceFresh: true })])

    if (!playerPosition.byKey[`${params.targetTileX},${params.targetTileY}`]) {
      return {
        status: false,
        message: "Player cannot move to destination tile, cannot gather resources",
      }
    }

    //MANUAL CODE - END

    const data: TDoGatherResourcesOnMapTileParams = {
      playerId: playerId,
      mapId: mapId,
      x: params.targetTileX,
      y: params.targetTileY,
      mapTilesResourceId: params.mapTilesResourceId,
      gatherAmount: 1,
    }

    const result = await doGatherResourcesOnMapTile(data)
    return result
  } catch (error) {
    console.error("Error doGatherResourcesOnMapTileService :", {
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
