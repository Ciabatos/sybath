---
name: ai-doOtherPlayerKnowledgeAcceptAction-description
description: |
  Action doOtherPlayerKnowledgeAcceptAction description, workflow.

  Use when:
  When using action doOtherPlayerKnowledgeAcceptAction or trying to understand it.
---

# doOtherPlayerKnowledgeAcceptAction Action Documentation

# function path :`methods/actions/knowledge/doOtherPlayerKnowledgeAcceptAction.ts`

# function doOtherPlayerKnowledgeAcceptAction(params: TDoOtherPlayerKnowledgeAcceptActionParams)

# TypeScript Types:

type TDoOtherPlayerKnowledgeAcceptActionParams = Omit<TDoOtherPlayerKnowledgeAcceptServiceParams, "sessionUserId"></T>

### Data Flow

```
# function doOtherPlayerKnowledgeAcceptService(params: TDoOtherPlayerKnowledgeAcceptServiceParams)
path: `methods/services/knowledge/doOtherPlayerKnowledgeAcceptService.ts`
# TypeScript Types:

export type TDoOtherPlayerKnowledgeAcceptServiceParams = {
sessionUserId: number
playerId: number
}


 Database function doOtherPlayerKnowledgeAccept(params: TDoOtherPlayerKnowledgeAcceptParams)
# path: `db/postgresMainDatabase/schemas/knowledge/doOtherPlayerKnowledgeAccept.ts`
# TypeScript Types:


export type TDoOtherPlayerKnowledgeAcceptParams = {
  playerId: number
  inviteId: number
}

export type TDoOtherPlayerKnowledgeAccept = {
  status: boolean
  message: string
}

#### PostgreSQL Database
# "schema": "knowledge"
# "method": "do_other_player_knowledge_accept"
You have more information in mcp `game-db`
```

Note: doOtherPlayerKnowledgeAcceptAction is a Next.js Server Action A Next.js Server Action is a function that: Runs on
the server Can be called directly from a React component Is typically triggered by form submissions or user interactions
Eliminates the need for manual API endpoints
