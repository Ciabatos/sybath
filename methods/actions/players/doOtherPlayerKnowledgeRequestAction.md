---
name: ai-doOtherPlayerKnowledgeRequestAction-description
description: |
  Action doOtherPlayerKnowledgeRequestAction description, workflow.

  Use when:
  When using action doOtherPlayerKnowledgeRequestAction or trying to understand it.
---

# doOtherPlayerKnowledgeRequestAction Action Documentation

# function path :`methods/actions/players/doOtherPlayerKnowledgeRequestAction.ts`

# function doOtherPlayerKnowledgeRequestAction(params: TDoOtherPlayerKnowledgeRequestActionParams)

# TypeScript Types:

type TDoOtherPlayerKnowledgeRequestActionParams = Omit<TDoOtherPlayerKnowledgeRequestServiceParams, "sessionUserId"></T>

### Data Flow

```
# function doOtherPlayerKnowledgeRequestService(params: TDoOtherPlayerKnowledgeRequestServiceParams)
path: `methods/services/players/doOtherPlayerKnowledgeRequestService.ts`
# TypeScript Types:

export type TDoOtherPlayerKnowledgeRequestServiceParams = {
sessionUserId: number
playerId: number
}


 Database function doOtherPlayerKnowledgeRequest(params: TDoOtherPlayerKnowledgeRequestParams)
# path: `db/postgresMainDatabase/schemas/players/doOtherPlayerKnowledgeRequest.ts`
# TypeScript Types:


export type TDoOtherPlayerKnowledgeRequestParams = {
  playerId: number
  otherPlayerId: string
  knowledgeTypeId: number
}

export type TDoOtherPlayerKnowledgeRequest = {
  status: boolean
  message: string
}

#### PostgreSQL Database
# "schema": "players"
# "method": "do_other_player_knowledge_request"
You have more information in mcp `game-db`
```

Note: doOtherPlayerKnowledgeRequestAction is a Next.js Server Action A Next.js Server Action is a function that: Runs on
the server Can be called directly from a React component Is typically triggered by form submissions or user interactions
Eliminates the need for manual API endpoints
