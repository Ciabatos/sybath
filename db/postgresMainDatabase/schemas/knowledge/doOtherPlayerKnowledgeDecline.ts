// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoOtherPlayerKnowledgeDeclineParams = {
  playerId: number
  inviteId: number
}

export type TDoOtherPlayerKnowledgeDecline = {
  status: boolean
  message: string
}

export async function doOtherPlayerKnowledgeDecline(params: TDoOtherPlayerKnowledgeDeclineParams) {
  try {
    const sqlParams = [params.playerId, params.inviteId]
    const sql = `SELECT * FROM knowledge.do_other_player_knowledge_decline($1, $2);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TDoOtherPlayerKnowledgeDecline
  } catch (error) {
    console.error("Error executing doOtherPlayerKnowledgeDecline:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doOtherPlayerKnowledgeDecline")
  }
}
