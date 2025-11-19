// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TMapMapTilesParams = {
  x: number
  y: number
}

export type TMapMapTiles = {
  mapId: number
  x: number
  y: number
  terrainTypeId: number
  landscapeTypeId?: number
}

export type TMapMapTilesRecordByXY = Record<string, TMapMapTiles>

export async function getMapMapTiles() {
  try {
    const sql = `SELECT * FROM map.get_map_tiles();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TMapMapTiles[]
  } catch (error) {
    console.error("Error fetching getMapMapTiles:", error)
    throw new Error("Failed to fetch getMapMapTiles")
  }
}

export async function getMapMapTilesByKey(params: TMapMapTilesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM map.get_map_tiles_by_key($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TMapMapTiles[]
  } catch (error) {
    console.error("Error fetching getMapMapTilesByKey:", error)
    throw new Error("Failed to fetch getMapMapTilesByKey")
  }
}
