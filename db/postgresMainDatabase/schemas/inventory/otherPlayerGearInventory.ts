// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherPlayerGearInventoryParams = {
  playerId: number
  otherPlayerMaskId: string
}

export type TOtherPlayerGearInventory = {
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  name: string
  quantity: number
}

export type TOtherPlayerGearInventoryRecordBySlotId = Record<string, TOtherPlayerGearInventory>

export async function getOtherPlayerGearInventory(params: TOtherPlayerGearInventoryParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM inventory.get_other_player_gear_inventory($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TOtherPlayerGearInventory[]
  } catch (error) {
    console.error("Error fetching getOtherPlayerGearInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getOtherPlayerGearInventory")
  }
}
