// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetTable.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TAttributesPlayerStatsParams = {
  playerId: number
}

export type TAttributesPlayerStats = {
  id: number
  playerId: number
  statId: number
  value: number
}

export type TAttributesPlayerStatsRecordByPlayerId = Record<string, TAttributesPlayerStats>

export async function getAttributesPlayerStats() {
  try {
    const sql = `SELECT * FROM attributes.get_player_stats();`

    const result = await query(sql)
    return snakeToCamelRows(result.rows) as TAttributesPlayerStats[]
  } catch (error) {
    console.error("Error fetching getAttributesPlayerStats:", error)
    throw new Error("Failed to fetch getAttributesPlayerStats")
  }
}

export async function getAttributesPlayerStatsByKey(params: TAttributesPlayerStatsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM attributes.get_player_stats_by_key($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TAttributesPlayerStats[]
  } catch (error) {
    console.error("Error fetching getAttributesPlayerStatsByKey:", error)
    throw new Error("Failed to fetch getAttributesPlayerStatsByKey")
  }
}
