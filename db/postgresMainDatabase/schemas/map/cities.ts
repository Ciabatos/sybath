// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TMapCitiesParams = {
  id: number
}

export type TMapCities = {
  id: number
  mapTileX: number
  mapTileY: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TMapCitiesRecordByMapTileXMapTileY = Record<string, TMapCities>

export async function getMapCities() {
  try {
    const sql = `SELECT * FROM map.get_cities();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TMapCities[]
  } catch (error) {
    console.error("Error fetching getMapCities:", error)
    throw new Error("Failed to fetch getMapCities")
  }
}

export async function getMapCitiesByKey(params: TMapCitiesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM map.get_cities_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TMapCities[]
  } catch (error) {
    console.error("Error fetching getMapCitiesByKey:", error)
    throw new Error("Failed to fetch getMapCitiesByKey")
  }
}
