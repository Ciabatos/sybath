---
name: ai-doOtherPlayerKnowledgeDeclineAction-description
description: |
  Action doOtherPlayerKnowledgeDeclineAction description, workflow.

  Use when:
  When using action doOtherPlayerKnowledgeDeclineAction or trying to understand it.
---

# doOtherPlayerKnowledgeDeclineAction Action Documentation

# function path :`methods/actions/knowledge/doOtherPlayerKnowledgeDeclineAction.ts`

# function doOtherPlayerKnowledgeDeclineAction(params: TDoOtherPlayerKnowledgeDeclineActionParams)

# TypeScript Types:

type TDoOtherPlayerKnowledgeDeclineActionParams = Omit<TDoOtherPlayerKnowledgeDeclineServiceParams, "sessionUserId"></T>

### Data Flow

```
# function doOtherPlayerKnowledgeDeclineService(params: TDoOtherPlayerKnowledgeDeclineServiceParams)
path: `methods/services/knowledge/doOtherPlayerKnowledgeDeclineService.ts`
# TypeScript Types:

export type TDoOtherPlayerKnowledgeDeclineServiceParams = {
sessionUserId: number
playerId: number
}


 Database function doOtherPlayerKnowledgeDecline(params: TDoOtherPlayerKnowledgeDeclineParams)
# path: `db/postgresMainDatabase/schemas/knowledge/doOtherPlayerKnowledgeDecline.ts`
# TypeScript Types:


export type TDoOtherPlayerKnowledgeDeclineParams = {
  playerId: number
  inviteId: number
}

export type TDoOtherPlayerKnowledgeDecline = {
  status: boolean
  message: string
}

#### PostgreSQL Database
# "schema": "knowledge"
# "method": "do_other_player_knowledge_decline"
You have more information in mcp `game-db`
```

Note: doOtherPlayerKnowledgeDeclineAction is a Next.js Server Action A Next.js Server Action is a function that: Runs on
the server Can be called directly from a React component Is typically triggered by form submissions or user interactions
Eliminates the need for manual API endpoints
