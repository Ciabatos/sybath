// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TWorldMapTilesPlayersPositionsParams = {
  playerId: number
}

export type TWorldMapTilesPlayersPositions = {
  playerId: number
  mapId: number
  mapTileX: number
  mapTileY: number
}

export type TWorldMapTilesPlayersPositionsRecordByMapIdMapTileXMapTileY = Record<string, TWorldMapTilesPlayersPositions>

export async function getWorldMapTilesPlayersPositions() {
  try {
    const sql = `SELECT * FROM world.get_map_tiles_players_positions();`
    
    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TWorldMapTilesPlayersPositions[]
  } catch (error) {
    console.error("Error fetching getWorldMapTilesPlayersPositions:", error)
    throw new Error("Failed to fetch getWorldMapTilesPlayersPositions")
  }
}

export async function getWorldMapTilesPlayersPositionsByKey(params: TWorldMapTilesPlayersPositionsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_map_tiles_players_positions_by_key($1);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TWorldMapTilesPlayersPositions[]
  } catch (error) {
    console.error("Error fetching getWorldMapTilesPlayersPositionsByKey:", error)
    throw new Error("Failed to fetch getWorldMapTilesPlayersPositionsByKey")
  }
}