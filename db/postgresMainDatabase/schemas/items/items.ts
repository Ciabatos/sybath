// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TItemsItemsParams = {
  id: number
}

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TItemsItemsParamsFetchParams = Partial<TItemsItemsParams>

export type TItemsItems = {
  id: number
  name: string
  description: string
  image: string
  itemTypeId: number
}

export type TItemsItemsRecordById = Record<string, TItemsItems>

export async function getItemsItems() {
  try {
    const sql = `SELECT * FROM items.get_items();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TItemsItems[]
  } catch (error) {
    console.error("Error fetching getItemsItems:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getItemsItems")
  }
}

export async function getItemsItemsByKey(params: TItemsItemsParams) {
  try {
    const sqlParams = [params.id]
    const sql = `SELECT * FROM items.get_items_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TItemsItems[]
  } catch (error) {
    console.error("Error fetching getItemsItemsByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getItemsItemsByKey")
  }
}
