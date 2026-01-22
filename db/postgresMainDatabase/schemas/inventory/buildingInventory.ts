// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TBuildingInventoryParams = {
  buildingId: number
}

export type TBuildingInventory = {
  slotId: number
  containerId: number
  itemId: number
  name: string
  quantity: number
}

export type TBuildingInventoryRecordBySlotId = Record<string, TBuildingInventory>

export async function getBuildingInventory(params: TBuildingInventoryParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM inventory.get_building_inventory($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TBuildingInventory[]
  } catch (error) {
    console.error("Error fetching getBuildingInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to fetch getBuildingInventory")
  }
}