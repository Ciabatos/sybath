import { TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId } from "@/db/postgresMainDatabase/schemas/knowledge/otherPlayerKnowledgeRequests"
import { atom } from "jotai"

export const otherPlayerKnowledgeRequestsAtom =
  atom<TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId>({})
