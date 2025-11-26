// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TCitiesCityTilesParams = {
  cityId: number
  x: number
  y: number
}

export type TCitiesCityTiles = {
  cityId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId?: number
}

export type TCitiesCityTilesRecordByCityIdXY = Record<string, TCitiesCityTiles>

export async function getCitiesCityTiles() {
  try {
    const sql = `SELECT * FROM cities.get_city_tiles();`
    
    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TCitiesCityTiles[]
  } catch (error) {
    console.error("Error fetching getCitiesCityTiles:", error)
    throw new Error("Failed to fetch getCitiesCityTiles")
  }
}

export async function getCitiesCityTilesByKey(params: TCitiesCityTilesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM cities.get_city_tiles_by_key($1, $2, $3);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TCitiesCityTiles[]
  } catch (error) {
    console.error("Error fetching getCitiesCityTilesByKey:", error)
    throw new Error("Failed to fetch getCitiesCityTilesByKey")
  }
}