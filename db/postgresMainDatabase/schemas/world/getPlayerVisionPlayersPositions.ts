// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TGetPlayerVisionPlayersPositionsParams = {
  mapId: number
  playerId: number
}

export type TGetPlayerVisionPlayersPositions = {
  x: number
  y: number
  imageUrl: string
}

export type TGetPlayerVisionPlayersPositionsRecordByXY = Record<string, TGetPlayerVisionPlayersPositions>

export async function getPlayerVisionPlayersPositions(params: TGetPlayerVisionPlayersPositionsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_player_vision_players_positions($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TGetPlayerVisionPlayersPositions[]
  } catch (error) {
    console.error("Error fetching getPlayerVisionPlayersPositions:", error)
    throw new Error("Failed to fetch getPlayerVisionPlayersPositions")
  }
}
