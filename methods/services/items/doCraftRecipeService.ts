// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoCraftRecipeParams, doCraftRecipe } from "@/db/postgresMainDatabase/schemas/items/doCraftRecipe"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"

//MANUAL CODE - START

export type TDoCraftRecipeServiceParams = {
  sessionUserId: number
  playerId: number
  recipeId: number
}

//MANUAL CODE - END

export async function doCraftRecipeService(params: TDoCraftRecipeServiceParams) {
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

    const recipeId = params.recipeId

    //MANUAL CODE - END

    const data: TDoCraftRecipeParams = {
      playerId: playerId,
      recipeId: recipeId,
    }
    console.log("doCraftRecipeService - data:", data)
    const result = await doCraftRecipe(data)
    return result
  } catch (error) {
    console.error("Error doCraftRecipeService :", {
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
