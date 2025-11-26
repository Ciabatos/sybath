// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerVisibleMapDataParams = {
  playerId: number
}


export type TPlayerVisibleMapData = {
  playerId: number
  playerName: string
  playerImageUrl: string
  mapTileX: number
  mapTileY: number
}

export type TPlayerVisibleMapDataRecordByMapTileXMapTileY = Record<string, TPlayerVisibleMapData>

export async function getPlayerVisibleMapData(params: TPlayerVisibleMapDataParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.player_visible_map_data($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerVisibleMapData[]
  } catch (error) {
    console.error("Error fetching getPlayerVisibleMapData:", error)
    throw new Error("Failed to fetch getPlayerVisibleMapData")
  }
}