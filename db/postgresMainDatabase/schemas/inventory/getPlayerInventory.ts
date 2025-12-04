// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TGetPlayerInventoryParams = {
  playerId: number
}

export type TGetPlayerInventory = {
  slotId: number
  containerId: number
  itemId: number
  name: string
  quantity: number
}

export type TGetPlayerInventoryRecordBySlotId = Record<string, TGetPlayerInventory>

export async function getGetPlayerInventory(params: TGetPlayerInventoryParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM inventory.get_player_inventory($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TGetPlayerInventory[]
  } catch (error) {
    console.error("Error fetching getGetPlayerInventory:", error)
    throw new Error("Failed to fetch getGetPlayerInventory")
  }
}
