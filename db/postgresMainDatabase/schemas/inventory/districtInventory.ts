// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TDistrictInventoryParams = {
  districtId: number
}

export type TDistrictInventory = {
  slotId: number
  containerId: number
  itemId: number
  name: string
  quantity: number
}

export type TDistrictInventoryRecordBySlotId = Record<string, TDistrictInventory>

export async function getDistrictInventory(params: TDistrictInventoryParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM inventory.get_district_inventory($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TDistrictInventory[]
  } catch (error) {
    console.error("Error fetching getDistrictInventory:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to fetch getDistrictInventory")
  }
}