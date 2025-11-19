// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/snakeToCamel"

export type TMapCityTilesParams = {
  x: number
  y: number
}

export type TMapCityTiles = {
  cityId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId?: number
}

export type TMapCityTilesRecordByXY = Record<string, TMapCityTiles>

export async function getMapCityTiles() {
  try {
    const sql = `SELECT * FROM map.get_city_tiles();`
    
    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TMapCityTiles[]
  } catch (error) {
    console.error("Error fetching getMapCityTiles:", error)
    throw new Error("Failed to fetch getMapCityTiles")
  }
}

export async function getMapCityTilesByKey(params: TMapCityTilesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM map.get_city_tiles_by_key($1, $2);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TMapCityTiles[]
  } catch (error) {
    console.error("Error fetching getMapCityTilesByKey:", error)
    throw new Error("Failed to fetch getMapCityTilesByKey")
  }
}