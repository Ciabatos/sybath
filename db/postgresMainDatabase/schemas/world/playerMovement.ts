// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TPlayerMovementParams = {
  playerId: number
}

export type TPlayerMovement = {
  order: number
  moveCost: number
  x: number
  y: number
  totalMoveCost: number
}

export type TPlayerMovementRecordByXY = Record<string, TPlayerMovement>

export async function getPlayerMovement(params: TPlayerMovementParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_player_movement($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TPlayerMovement[]
  } catch (error) {
    console.error("Error fetching getPlayerMovement:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getPlayerMovement")
  }
}
