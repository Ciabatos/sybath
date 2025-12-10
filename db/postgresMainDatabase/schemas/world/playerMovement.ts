// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TPlayerMovementParams = {
  playerId: number
  path: any
}

export type TPlayerMovement = {
  status: string
  message: string
}

export async function playerMovement(params: TPlayerMovementParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.player_movement($1, $2);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TPlayerMovement
  } catch (error) {
    console.error("Error executing playerMovement:", error)
    throw new Error("Failed to execute playerMovement")
  }
}
