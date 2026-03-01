// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import {
  TDoGatherResourcesOnMapTileParams,
  doGatherResourcesOnMapTile,
} from "@/db/postgresMainDatabase/schemas/items/doGatherResourcesOnMapTile"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"
import { getPlayerMovementServer } from "@/methods/server-fetchers/world/core/getPlayerMovementServer"

//MANUAL CODE - START

export type TDoGatherResourcesOnMapTileServiceParams = {
  sessionUserId: number
  playerId: number
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

    const [playerMovement] = await Promise.all([getPlayerMovementServer({ playerId })])

    if (!playerMovement.byKey[`${params.targetTileX},${params.targetTileY}`]) {
      return {
        status: false,
        message: "Player cannot move to destination tile, cannot gather resources",
      }
    }

    const parameters = [
      {
        x: params.targetTileX,
        y: params.targetTileY,
        mapTilesResourceId: params.mapTilesResourceId,
        gatherAmount: params.gatherAmount,
      },
    ]

    //MANUAL CODE - END

    const data: TDoGatherResourcesOnMapTileParams = {
      playerId: playerId,
      parameters: parameters,
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
