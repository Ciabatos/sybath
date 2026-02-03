// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerInventoryParams = {
  playerId: number
}

export type TPlayerInventory = {
  slotId: number
  containerId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TPlayerInventoryRecordBySlotId = Record<string, TPlayerInventory>

export async function getPlayerInventory(params: TPlayerInventoryParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM inventory.get_player_inventory($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerInventory[]
  } catch (error) {
    console.error("Error fetching getPlayerInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to fetch getPlayerInventory")
  }
}