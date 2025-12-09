// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TGetPlayerMovementParams = {
  playerId: number
}

export type TGetPlayerMovement = {
  scheduledAt: string
  x: number
  y: number
}

export type TGetPlayerMovementRecordByXY = Record<string, TGetPlayerMovement>

export async function getPlayerMovement(params: TGetPlayerMovementParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.get_player_movement($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TGetPlayerMovement[]
  } catch (error) {
    console.error("Error fetching getPlayerMovement:", error)
    throw new Error("Failed to fetch getPlayerMovement")
  }
}
