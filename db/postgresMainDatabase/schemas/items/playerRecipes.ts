// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerRecipesParams = {
  playerId: number
}

export type TPlayerRecipes = {
  id: number
  itemId: number
  description: string
  image: string
  skillId: number
  value: number
  canCraft: boolean
}

export type TPlayerRecipesRecordByItemId = Record<string, TPlayerRecipes>

export async function getPlayerRecipes(params: TPlayerRecipesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM items.get_player_recipes($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerRecipes[]
  } catch (error) {
    console.error("Error fetching getPlayerRecipes:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerRecipes")
  }
}
