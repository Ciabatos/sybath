// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoCraftRecipeParams = {
  playerId: number
  recipeId: number
}

export type TDoCraftRecipe = {
  status: boolean
  message: string
}

export async function doCraftRecipe(params: TDoCraftRecipeParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM items.do_craft_recipe($1, $2);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TDoCraftRecipe
  } catch (error) {
    console.error("Error executing doCraftRecipe:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doCraftRecipe")
  }
}
