// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodAction.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"

export type TDoOtherPlayerKnowledgeAcceptParams = {
  playerId: number
  inviteId: number
}

export type TDoOtherPlayerKnowledgeAccept = {
  status: boolean
  message: string
}

export async function doOtherPlayerKnowledgeAccept(params: TDoOtherPlayerKnowledgeAcceptParams) {
  try {
    const sqlParams = [params.playerId, params.inviteId]
    const sql = `SELECT * FROM knowledge.do_other_player_knowledge_accept($1, $2);`
    const result = await query(sql, sqlParams)

    return result.rows[0] as TDoOtherPlayerKnowledgeAccept
  } catch (error) {
    console.error("Error executing doOtherPlayerKnowledgeAccept:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to execute doOtherPlayerKnowledgeAccept")
  }
}
