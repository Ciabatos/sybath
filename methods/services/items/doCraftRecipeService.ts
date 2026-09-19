// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoCraftRecipeParams, doCraftRecipe } from "@/db/postgresMainDatabase/schemas/items/doCraftRecipe"

//MANUAL CODE - START

export type TDoCraftRecipeServiceParams = {
  sessionUserId: string
  playerId: number
  recipeId: number
}

//MANUAL CODE - END

export async function doCraftRecipeService(params: TDoCraftRecipeServiceParams) {
  try {
    const sessionPlayerId = params.sessionUserId
    const playerId = params.playerId

    //MANUAL CODE - START

    const recipeId = params.recipeId

    //MANUAL CODE - END

    const data: TDoCraftRecipeParams = {
      playerId: playerId,
      recipeId: recipeId,
    }
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
