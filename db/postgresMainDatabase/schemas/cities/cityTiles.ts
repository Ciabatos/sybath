// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TCitiesCityTilesParams = {
  cityId: number
}

export type TCitiesCityTiles = {
  cityId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId?: number
}

export type TCitiesCityTilesRecordByXY = Record<string, TCitiesCityTiles>

export async function getCitiesCityTiles() {
  try {
    const sql = `SELECT * FROM cities.get_city_tiles();`
    
    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TCitiesCityTiles[]
  } catch (error) {
    console.error("Error fetching getCitiesCityTiles:", {
      error,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to fetch getCitiesCityTiles")
  }
}

export async function getCitiesCityTilesByKey(params: TCitiesCityTilesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM cities.get_city_tiles_by_key($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TCitiesCityTiles[]
  } catch (error) {
    console.error("Error fetching getCitiesCityTilesByKey:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getCitiesCityTilesByKey")
  }
}