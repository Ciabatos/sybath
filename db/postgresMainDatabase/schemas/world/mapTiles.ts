// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TWorldMapTilesParams = {
  mapId: number
}

export type TWorldMapTiles = {
  mapId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId?: number
}

export type TWorldMapTilesRecordByXY = Record<string, TWorldMapTiles>

export async function getWorldMapTiles() {
  try {
    const sql = `SELECT * FROM world.get_map_tiles();`
    
    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TWorldMapTiles[]
  } catch (error) {
    console.error("Error fetching getWorldMapTiles:", error)
    throw new Error("Failed to fetch getWorldMapTiles")
  }
}

export async function getWorldMapTilesByKey(params: TWorldMapTilesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_map_tiles_by_key($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TWorldMapTiles[]
  } catch (error) {
    console.error("Error fetching getWorldMapTilesByKey:", error)
    throw new Error("Failed to fetch getWorldMapTilesByKey")
  }
}