// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TItemsItemStatsParams = {
  id: number
}

export type TItemsItemStats = {
  id: number
  itemId: number
  statId: number
  value: number
}

export type TItemsItemStatsRecordByItemId = Record<string, TItemsItemStats>

export async function getItemsItemStats() {
  try {
    const sql = `SELECT * FROM items.get_item_stats();`
    
    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TItemsItemStats[]
  } catch (error) {
    console.error("Error fetching getItemsItemStats:", error)
    throw new Error("Failed to fetch getItemsItemStats")
  }
}

export async function getItemsItemStatsByKey(params: TItemsItemStatsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM items.get_item_stats_by_key($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TItemsItemStats[]
  } catch (error) {
    console.error("Error fetching getItemsItemStatsByKey:", error)
    throw new Error("Failed to fetch getItemsItemStatsByKey")
  }
}