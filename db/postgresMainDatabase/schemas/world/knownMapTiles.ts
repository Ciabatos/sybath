// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TKnownMapTilesParams = {
  mapId: number
  playerId: number
}

export type TKnownMapTiles = {
  mapId: number
  x: number
  y: number
  terrainTypeId?: number
  landscapeTypeId?: number
}

export type TKnownMapTilesRecordByXY = Record<string, TKnownMapTiles>

export async function getKnownMapTiles(params: TKnownMapTilesParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_known_map_tiles($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TKnownMapTiles[]
  } catch (error) {
    console.error("Error fetching getKnownMapTiles:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getKnownMapTiles")
  }
}
