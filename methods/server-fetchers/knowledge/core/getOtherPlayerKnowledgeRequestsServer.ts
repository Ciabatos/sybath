// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TOtherPlayerKnowledgeRequestsParams } from "@/db/postgresMainDatabase/schemas/knowledge/otherPlayerKnowledgeRequests"
import type {
  TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId,
  TOtherPlayerKnowledgeRequests,
} from "@/db/postgresMainDatabase/schemas/knowledge/otherPlayerKnowledgeRequests"
import { fetchOtherPlayerKnowledgeRequestsService } from "@/methods/services/knowledge/fetchOtherPlayerKnowledgeRequestsService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TOtherPlayerKnowledgeRequests[]
  byKey: TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getOtherPlayerKnowledgeRequestsServer(
  params: TOtherPlayerKnowledgeRequestsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchOtherPlayerKnowledgeRequestsService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/knowledge/rpc/get-other-player-knowledge-requests/${params.playerId}`,
    atomName: `otherPlayerKnowledgeRequestsAtom`,
  }
}
