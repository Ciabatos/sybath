// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoSquadInviteParams = {
  playerId: number
  invitedPlayerId: string
}

export type TDoSquadInvite = {
  status: boolean
  message: string
}

export async function doSquadInvite(params: TDoSquadInviteParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM squad.do_squad_invite($1, $2);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TDoSquadInvite
  } catch (error) {
    console.error("Error executing doSquadInvite:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doSquadInvite")
  }
}
