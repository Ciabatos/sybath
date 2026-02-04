// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerGearInventoryParams = {
  playerId: number
}

export type TPlayerGearInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TPlayerGearInventoryRecordBySlotId = Record<string, TPlayerGearInventory>

export async function getPlayerGearInventory(params: TPlayerGearInventoryParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM inventory.get_player_gear_inventory($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerGearInventory[]
  } catch (error) {
    console.error("Error fetching getPlayerGearInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to fetch getPlayerGearInventory")
  }
}