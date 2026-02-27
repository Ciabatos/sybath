// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import {
  TDoMapTileExplorationParams,
  doMapTileExploration,
} from "@/db/postgresMainDatabase/schemas/world/doMapTileExploration"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getPlayerAbilitiesServer"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"
import { getPlayerMovementServer } from "@/methods/server-fetchers/world/core/getPlayerMovementServer"

//MANUAL CODE - START

export type TDoMapTileExplorationServiceParams = {
  sessionUserId: number
  playerId: number
  targetTileX: number
  targetTileY: number
}

//MANUAL CODE - END

export async function doMapTileExplorationService(params: TDoMapTileExplorationServiceParams) {
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
    const [playerAbilities, playerMovement] = await Promise.all([
      getPlayerAbilitiesServer({ playerId }),
      getPlayerMovementServer({ playerId }),
    ])

    if (!playerAbilities.byKey[2]?.value) {
      return {
        status: false,
        message: "Player does not have exploration ability",
      }
    }

    if (!playerMovement.byKey[`${params.targetTileX},${params.targetTileY}`]) {
      return {
        status: false,
        message: "Player cannot move to destination tile, cannot explore",
      }
    }

    const parameters = [
      {
        x: params.targetTileX,
        y: params.targetTileY,
        explorationLevel: playerAbilities.byKey[2].value,
      },
    ]

    //MANUAL CODE - END

    const data: TDoMapTileExplorationParams = {
      playerId: playerId,
      parameters: parameters,
    }

    const result = await doMapTileExploration(data)
    return result
  } catch (error) {
    console.error("Error doMapTileExplorationService :", {
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
