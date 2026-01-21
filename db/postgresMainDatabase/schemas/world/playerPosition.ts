// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerPositionParams = {
  mapId: number
  playerId: number
}

export type TPlayerPosition = {
  x: number
  y: number
  imageMap: string
}

export type TPlayerPositionRecordByXY = Record<string, TPlayerPosition>

export async function getPlayerPosition(params: TPlayerPositionParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_player_position($1, $2);`
    
    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerPosition[]
  } catch (error) {
    console.error("Error fetching getPlayerPosition:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to fetch getPlayerPosition")
  }
}