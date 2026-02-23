// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherPlayerStatsParams = {
  playerId: number
  otherPlayerMaskId: string
}

export type TOtherPlayerStats = {
  statId: number
  value: number
  name: string
}

export type TOtherPlayerStatsRecordByStatId = Record<string, TOtherPlayerStats>

export async function getOtherPlayerStats(params: TOtherPlayerStatsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_other_player_stats($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TOtherPlayerStats[]
  } catch (error) {
    console.error("Error fetching getOtherPlayerStats:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getOtherPlayerStats")
  }
}
