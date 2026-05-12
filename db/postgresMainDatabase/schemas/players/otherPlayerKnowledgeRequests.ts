// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherPlayerKnowledgeRequestsParams = {
  playerId: number
}

export type TOtherPlayerKnowledgeRequests = {
  otherPlayerKnowledgeRequestId: number
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imagePortrait: string
  knowledgeTypeId: number
  createdAt: string
}

export type TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId = Record<
  string,
  TOtherPlayerKnowledgeRequests
>

export async function getOtherPlayerKnowledgeRequests(params: TOtherPlayerKnowledgeRequestsParams) {
  try {
    const sqlParams = Object.values(params)
    const sql = `SELECT * FROM players.get_other_player_knowledge_requests($1);`

    const result = await query(sql, sqlParams)
    return snakeToCamelRows(result.rows) as TOtherPlayerKnowledgeRequests[]
  } catch (error) {
    console.error("Error fetching getOtherPlayerKnowledgeRequests:", {
      error,
      params,
      timestamp: new Date().toISOString(),
    })

    throw new Error("Failed to fetch getOtherPlayerKnowledgeRequests")
  }
}
