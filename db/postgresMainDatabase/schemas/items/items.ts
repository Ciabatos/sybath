// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TItemsItemsParams = {
  id: number
}

export type TItemsItems = {
  id: number
  name?: string
}

export type TItemsItemsRecordById = Record<string, TItemsItems>

export async function getItemsItems() {
  try {
    const sql = `SELECT * FROM items.get_items();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TItemsItems[]
  } catch (error) {
    console.error("Error fetching getItemsItems:", error)
    throw new Error("Failed to fetch getItemsItems")
  }
}

export async function getItemsItemsByKey(params: TItemsItemsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM items.get_items_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TItemsItems[]
  } catch (error) {
    console.error("Error fetching getItemsItemsByKey:", error)
    throw new Error("Failed to fetch getItemsItemsByKey")
  }
}
