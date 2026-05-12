// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TOtherPlayerKnowledgeRequestsParams } from "@/db/postgresMainDatabase/schemas/players/otherPlayerKnowledgeRequests"
import type {
  TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId,
  TOtherPlayerKnowledgeRequests,
} from "@/db/postgresMainDatabase/schemas/players/otherPlayerKnowledgeRequests"
import { fetchOtherPlayerKnowledgeRequestsService } from "@/methods/services/players/fetchOtherPlayerKnowledgeRequestsService"

type TResult = {
  raw: TOtherPlayerKnowledgeRequests[]
  byKey: TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId
  apiPath: string
  atomName: string
}

export async function getOtherPlayerKnowledgeRequestsServer(
  params: TOtherPlayerKnowledgeRequestsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchOtherPlayerKnowledgeRequestsService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/players/rpc/get-other-player-knowledge-requests/${params.playerId}`,
    atomName: `otherPlayerKnowledgeRequestsAtom`,
  }
}
