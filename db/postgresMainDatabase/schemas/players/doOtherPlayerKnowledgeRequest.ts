// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoOtherPlayerKnowledgeRequestParams = {
  playerId: number
  otherPlayerId: string
  knowledgeTypeId: number
}

export type TDoOtherPlayerKnowledgeRequest = {
  status: boolean
  message: string
}

export async function doOtherPlayerKnowledgeRequest(params: TDoOtherPlayerKnowledgeRequestParams) {
  try {
    const sqlParams = [params.playerId, params.otherPlayerId, params.knowledgeTypeId]
    const sql = `SELECT * FROM players.do_other_player_knowledge_request($1, $2, $3);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TDoOtherPlayerKnowledgeRequest
  } catch (error) {
    console.error("Error executing doOtherPlayerKnowledgeRequest:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doOtherPlayerKnowledgeRequest")
  }
}
