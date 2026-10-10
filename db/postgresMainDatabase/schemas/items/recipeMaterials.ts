// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TItemsRecipeMaterialsParams = {
  recipeId: number
}

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TItemsRecipeMaterialsParamsFetchParams = Partial<TItemsRecipeMaterialsParams>

export type TItemsRecipeMaterials = {
  id: number
  recipeId: number
  itemId: number
  quantity: number
}

export type TItemsRecipeMaterialsRecordById = Record<string, TItemsRecipeMaterials>

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
    const sqlParams = [params.recipeId]
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
