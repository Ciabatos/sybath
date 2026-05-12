---
name: ai-useFetchOtherPlayerKnowledgeRequests-description
description: |
  Hook useFetchOtherPlayerKnowledgeRequests description, workflow.

  Use when:
  When using hook useFetchOtherPlayerKnowledgeRequests or trying to understand it.
---

# useFetchOtherPlayerKnowledgeRequests hook Documentation

# function path :`methods/hooks/players/core/useFetchOtherPlayerKnowledgeRequests.ts`

# function useFetchOtherPlayerKnowledgeRequests( params: TOtherPlayerKnowledgeRequestsParams)

# Jotai atom name: const otherPlayerKnowledgeRequestsAtom = atom<TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/players/rpc/get-other-player-knowledge-requests/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TOtherPlayerKnowledgeRequestsParams>

# function getOtherPlayerKnowledgeRequestsServer( params: TOtherPlayerKnowledgeRequestsParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/players/core/getOtherPlayerKnowledgeRequestsServer.ts`
# TypeScript Types:

type TResult = {
  raw: TOtherPlayerKnowledgeRequests[]
  byKey: TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId
  apiPath: string
  atomName: string
}

# function getOtherPlayerKnowledgeRequests(params: TOtherPlayerKnowledgeRequestsParams)
# path: `db/postgresMainDatabase/schemas/players/otherPlayerKnowledgeRequests.ts`
# TypeScript Types:

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

export type TOtherPlayerKnowledgeRequestsRecordByOtherPlayerKnowledgeRequestId = Record<string, TOtherPlayerKnowledgeRequests>

Hook for mutate data using SWR
# function path :`methods/hooks/players/core/useMutateOtherPlayerKnowledgeRequests.ts`
# function useMutateOtherPlayerKnowledgeRequests( params: TOtherPlayerKnowledgeRequestsParams)

#### PostgreSQL Database
# "schema": "players"
# "method": "get_other_player_knowledge_requests"
You have more information in mcp `game-db`
```
