// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerStatsParams = {
  playerId: number
}

export type TPlayerStats = {
  statId: number
  value: number
  name: string
}

export type TPlayerStatsRecordByStatId = Record<string, TPlayerStats>

export async function getPlayerStats(params: TPlayerStatsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_player_stats($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerStats[]
  } catch (error) {
    console.error("Error fetching getPlayerStats:", error)
    throw new Error("Failed to fetch getPlayerStats")
  }
}
