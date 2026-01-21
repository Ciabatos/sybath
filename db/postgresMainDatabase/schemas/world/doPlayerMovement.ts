// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoPlayerMovementParams = {
  playerId: number
  path: any
}

export type TDoPlayerMovement = {
  status: boolean
  message: string
}

export async function doPlayerMovement(params: TDoPlayerMovementParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM world.do_player_movement($1, $2);`
    const result = await query(sql, sqlParams)


    return result.rows[0] as TDoPlayerMovement
  } catch (error) {
    console.error("Error executing doPlayerMovement:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to execute doPlayerMovement")
  }
}
