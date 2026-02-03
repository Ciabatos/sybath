// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TInventoryInventorySlotTypesParams = {
  id: number
}

export type TInventoryInventorySlotTypes = {
  id: number
  name?: string
}

export type TInventoryInventorySlotTypesRecordById = Record<string, TInventoryInventorySlotTypes>

export async function getInventoryInventorySlotTypes() {
  try {
    const sql = `SELECT * FROM inventory.get_inventory_slot_types();`
    
    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TInventoryInventorySlotTypes[]
  } catch (error) {
    console.error("Error fetching getInventoryInventorySlotTypes:", {
      error,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to fetch getInventoryInventorySlotTypes")
  }
}

export async function getInventoryInventorySlotTypesByKey(params: TInventoryInventorySlotTypesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM inventory.get_inventory_slot_types_by_key($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TInventoryInventorySlotTypes[]
  } catch (error) {
    console.error("Error fetching getInventoryInventorySlotTypesByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getInventoryInventorySlotTypesByKey")
  }
}