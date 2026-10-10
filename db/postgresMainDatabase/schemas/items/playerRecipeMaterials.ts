// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerRecipeMaterialsParams = {
  userId: string
  playerId: number
  recipeId: number
}

export type TPlayerRecipeMaterialsClientParams = Omit<TPlayerRecipeMaterialsParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TPlayerRecipeMaterialsFetchParams = Partial<TPlayerRecipeMaterialsClientParams>

export type TPlayerRecipeMaterials = {
  id: number
  recipeId: number
  itemId: number
  quantity: number
  ownedQuantity: number
  missingQuantity: number
  canCraftMissing: boolean
}

export type TPlayerRecipeMaterialsRecordById = Record<string, TPlayerRecipeMaterials>

export async function getPlayerRecipeMaterials(params: TPlayerRecipeMaterialsParams) {
  try {
    const sqlParams = [params.userId, params.playerId, params.recipeId]
    const sql = `SELECT * FROM items.get_player_recipe_materials($1, $2, $3);`

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
