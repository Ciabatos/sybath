// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelKeys } from "@/methods/functions/util/snakeToCamel"

export type TDoSpyOnOtherPlayerParams = {
  userId: string
  playerId: number
  otherPlayerId: string
  knowledgeTypeId: number
}

export type TDoSpyOnOtherPlayer = {
  status: boolean
  message: string
}

export async function doSpyOnOtherPlayer(params: TDoSpyOnOtherPlayerParams) {
  try {
    const sqlParams = [params.userId, params.playerId, params.otherPlayerId, params.knowledgeTypeId]
    const sql = `SELECT * FROM knowledge.do_spy_on_other_player($1, $2, $3, $4);`
    const result = await query(sql, sqlParams)

    return snakeToCamelKeys(result.rows[0]) as TDoSpyOnOtherPlayer
  } catch (error) {
    console.error("Error executing doSpyOnOtherPlayer:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doSpyOnOtherPlayer")
  }
}
