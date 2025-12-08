// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TGetActivePlayerVisionPlayersPositionsParams = {
  mapId: number
  playerId: number
}

export type TGetActivePlayerVisionPlayersPositions = {
  x: number
  y: number
  imageUrl: string
}

export type TGetActivePlayerVisionPlayersPositionsRecordByXY = Record<string, TGetActivePlayerVisionPlayersPositions>

export async function getGetActivePlayerVisionPlayersPositions(params: TGetActivePlayerVisionPlayersPositionsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_active_player_vision_players_positions($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TGetActivePlayerVisionPlayersPositions[]
  } catch (error) {
    console.error("Error fetching getGetActivePlayerVisionPlayersPositions:", error)
    throw new Error("Failed to fetch getGetActivePlayerVisionPlayersPositions")
  }
}
