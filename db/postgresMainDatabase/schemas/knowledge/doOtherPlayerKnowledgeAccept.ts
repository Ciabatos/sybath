// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelKeys } from "@/methods/functions/util/snakeToCamel"

export type TDoOtherPlayerKnowledgeAcceptParams = {
  userId: string
  playerId: number
  inviteId: number
}

export type TDoOtherPlayerKnowledgeAccept = {
  status: boolean
  message: string
}

export async function doOtherPlayerKnowledgeAccept(params: TDoOtherPlayerKnowledgeAcceptParams) {
  try {
    const sqlParams = [params.userId, params.playerId, params.inviteId]
    const sql = `SELECT * FROM knowledge.do_other_player_knowledge_accept($1, $2, $3);`
    const result = await query(sql, sqlParams)

    return snakeToCamelKeys(result.rows[0]) as TDoOtherPlayerKnowledgeAccept
  } catch (error) {
    console.error("Error executing doOtherPlayerKnowledgeAccept:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doOtherPlayerKnowledgeAccept")
  }
}
