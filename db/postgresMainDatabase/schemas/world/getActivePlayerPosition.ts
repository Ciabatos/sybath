// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TGetActivePlayerPositionParams = {
  mapId: number
  playerId: number
}

export type TGetActivePlayerPosition = {
  x: number
  y: number
}

export type TGetActivePlayerPositionRecordByXY = Record<string, TGetActivePlayerPosition>

export async function getGetActivePlayerPosition(params: TGetActivePlayerPositionParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_active_player_position($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TGetActivePlayerPosition[]
  } catch (error) {
    console.error("Error fetching getGetActivePlayerPosition:", error)
    throw new Error("Failed to fetch getGetActivePlayerPosition")
  }
}
