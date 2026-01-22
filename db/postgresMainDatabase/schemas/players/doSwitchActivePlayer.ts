// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoSwitchActivePlayerParams = {
  playerId: number
  switchToPlayerId: number
}

export type TDoSwitchActivePlayer = {
  status: boolean
  message: string
}

export async function doSwitchActivePlayer(params: TDoSwitchActivePlayerParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM players.do_switch_active_player($1, $2);`
    const result = await query(sql, sqlParams)


    return result.rows[0] as TDoSwitchActivePlayer
  } catch (error) {
    console.error("Error executing doSwitchActivePlayer:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })
    
    throw new Error("Failed to execute doSwitchActivePlayer")
  }
}
