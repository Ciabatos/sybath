// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelKeys } from "@/methods/functions/util/snakeToCamel"

export type TDoSquadJoinParams = {
  userId: string
  playerId: number
  squadInviteId: number
}

export type TDoSquadJoin = {
  status: boolean
  message: string
}

export async function doSquadJoin(params: TDoSquadJoinParams) {
  try {
    const sqlParams = [params.userId, params.playerId, params.squadInviteId]
    const sql = `SELECT * FROM squad.do_squad_join($1, $2, $3);`
    const result = await query(sql, sqlParams)

    return snakeToCamelKeys(result.rows[0]) as TDoSquadJoin
  } catch (error) {
    console.error("Error executing doSquadJoin:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doSquadJoin")
  }
}
