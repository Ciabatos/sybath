// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TCitiesCitiesParams = {
  mapId: number
}

export type TCitiesCities = {
  id: number
  mapId: number
  mapTileX: number
  mapTileY: number
  name: string
  moveCost: number
  imageUrl?: string
}

export type TCitiesCitiesRecordByMapTileXMapTileY = Record<string, TCitiesCities>

export async function getCitiesCities() {
  try {
    const sql = `SELECT * FROM cities.get_cities();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TCitiesCities[]
  } catch (error) {
    console.error("Error fetching getCitiesCities:", {
      error,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getCitiesCities")
  }
}

export async function getCitiesCitiesByKey(params: TCitiesCitiesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM cities.get_cities_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TCitiesCities[]
  } catch (error) {
    console.error("Error fetching getCitiesCitiesByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getCitiesCitiesByKey")
  }
}
