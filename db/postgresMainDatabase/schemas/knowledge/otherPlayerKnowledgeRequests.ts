// GENERATED CODE - DO NOT EDIT MANUALLY - dbGetMethodFetcher.hbs

"use server"
import { query } from "@/db/postgresMainDatabase/postgresMainDatabase"
import { snakeToCamelRows } from "@/methods/functions/util/snakeToCamel"

export type TOtherPlayerKnowledgeRequestsParams = {
  userId: string
  playerId: number
}

export type TOtherPlayerKnowledgeRequestsClientParams = Omit<TOtherPlayerKnowledgeRequestsParams, "userId">

/*
  Parametry dozwolone w części — hook fetchujący jest wołany bezwarunkowo
  (React zabrania zmieniać liczby hooków między renderami), a w composite'ie
  parametr bywa jeszcze nieznany, np. `clickedMapTile` przed kliknięciem.
  Niekompletne parametry dają klucz SWR `null`, a SWR nic wtedy nie odpytuje.
*/
export type TOtherPlayerKnowledgeRequestsFetchParams = Partial<TOtherPlayerKnowledgeRequestsClientParams>

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
    const sqlParams = [params.userId, params.playerId]
    const sql = `SELECT * FROM knowledge.get_other_player_knowledge_requests($1, $2);`

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
