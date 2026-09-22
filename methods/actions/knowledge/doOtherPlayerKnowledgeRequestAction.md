---
name: ai-doOtherPlayerKnowledgeRequestAction-description
description: |
  Action doOtherPlayerKnowledgeRequestAction description, workflow.

  Use when:
  When using action doOtherPlayerKnowledgeRequestAction or trying to understand it.
---

# doOtherPlayerKnowledgeRequestAction Action Documentation

# function path :`methods/actions/knowledge/doOtherPlayerKnowledgeRequestAction.ts`

# function doOtherPlayerKnowledgeRequestAction(params: TDoOtherPlayerKnowledgeRequestActionParams)

# TypeScript Types:

type TDoOtherPlayerKnowledgeRequestActionParams = Omit<TDoOtherPlayerKnowledgeRequestServiceParams, "sessionUserId"></T>

### Data Flow

function doOtherPlayerKnowledgeRequestService(params: TDoOtherPlayerKnowledgeRequestServiceParams) path:
methods/services/knowledge/doOtherPlayerKnowledgeRequestService.ts

TypeScript Types: export type TDoOtherPlayerKnowledgeRequestServiceParams = { sessionUserId: string playerId: number }

Database function doOtherPlayerKnowledgeRequest(params: TDoOtherPlayerKnowledgeRequestParams)

path: db/postgresMainDatabase/schemas/knowledge/doOtherPlayerKnowledgeRequest.ts TypeScript Types:

export type TDoOtherPlayerKnowledgeRequestParams = { userId: string playerId: number otherPlayerId: string
knowledgeTypeId: number }

export type TDoOtherPlayerKnowledgeRequest = { status: boolean message: string }

PostgreSQL Database "schema": "knowledge" "method": "do_other_player_knowledge_request" You have more information in mcp
game-db
