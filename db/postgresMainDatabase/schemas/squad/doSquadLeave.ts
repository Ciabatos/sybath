// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoSquadLeaveParams = {
  playerId: number
}

export type TDoSquadLeave = {
  status: boolean
  message: string
}

export async function doSquadLeave(params: TDoSquadLeaveParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM squad.do_squad_leave($1);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TDoSquadLeave
  } catch (error) {
    console.error("Error executing doSquadLeave:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doSquadLeave")
  }
}
