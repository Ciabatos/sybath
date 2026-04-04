// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerRecipeMaterialsParams = {
  playerId: number
  recipeId: number
}

export type TPlayerRecipeMaterials = {
  id: number
  recipeId: number
  itemId: number
  quantity: number
  ownedQuantity: number
  missingQuantity: number
}

export type TPlayerRecipeMaterialsRecordById = Record<string, TPlayerRecipeMaterials>

export async function getPlayerRecipeMaterials(params: TPlayerRecipeMaterialsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM items.get_player_recipe_materials($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerRecipeMaterials[]
  } catch (error) {
    console.error("Error fetching getPlayerRecipeMaterials:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerRecipeMaterials")
  }
}
