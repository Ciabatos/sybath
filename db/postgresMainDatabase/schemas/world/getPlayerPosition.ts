// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TGetPlayerPositionParams = {
  mapId: number
  playerId: number
}

export type TGetPlayerPosition = {
  x: number
  y: number
  imageUrl: string
}

export type TGetPlayerPositionRecordByXY = Record<string, TGetPlayerPosition>

export async function getPlayerPosition(params: TGetPlayerPositionParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_player_position($1, $2);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TGetPlayerPosition[]
  } catch (error) {
    console.error("Error fetching getPlayerPosition:", error)
    throw new Error("Failed to fetch getPlayerPosition")
  }
}
