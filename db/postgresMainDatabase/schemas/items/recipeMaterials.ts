// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TItemsRecipeMaterialsParams = {
  recipeId: number
}

export type TItemsRecipeMaterials = {
  id: number
  recipeId: number
  itemId: number
  quantity: number
}

export type TItemsRecipeMaterialsRecordByRecipeId = Record<string, TItemsRecipeMaterials>

export async function getItemsRecipeMaterials() {
  try {
    const sql = `SELECT * FROM items.get_recipe_materials();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TItemsRecipeMaterials[]
  } catch (error) {
    console.error("Error fetching getItemsRecipeMaterials:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getItemsRecipeMaterials")
  }
}

export async function getItemsRecipeMaterialsByKey(params: TItemsRecipeMaterialsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM items.get_recipe_materials_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TItemsRecipeMaterials[]
  } catch (error) {
    console.error("Error fetching getItemsRecipeMaterialsByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getItemsRecipeMaterialsByKey")
  }
}
