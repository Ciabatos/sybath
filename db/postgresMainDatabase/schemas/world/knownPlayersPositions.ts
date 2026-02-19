// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TKnownPlayersPositionsParams = {
  mapId: number
  playerId: number
}

export type TKnownPlayersPositions = {
  otherPlayerId: string
  x: number
  y: number
  imageMap: string
}

export type TKnownPlayersPositionsRecordByXY = Record<string, TKnownPlayersPositions>

export async function getKnownPlayersPositions(params: TKnownPlayersPositionsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_known_players_positions($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TKnownPlayersPositions[]
  } catch (error) {
    console.error("Error fetching getKnownPlayersPositions:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getKnownPlayersPositions")
  }
}
