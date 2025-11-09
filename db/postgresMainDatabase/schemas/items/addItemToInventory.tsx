// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TAddItemToInventoryParams = {
  playerId: number
  itemId: number
  quantity: number
}

export type TAddItemToInventory = {
  result: unknown
}

export async function addItemToInventory(params: TAddItemToInventoryParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT items.add_item_to_inventory($1, $2, $3);`
    const result = await query(sql, sqlParams)

    return result.rows[0]?.result as TAddItemToInventory
  } catch (error) {
    console.error("Error executing addItemToInventory:", error)
    throw new Error("Failed to execute addItemToInventory")
  }
}
