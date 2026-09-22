---
name: ai-doSpyOnOtherPlayerAction-description
description: |
  Action doSpyOnOtherPlayerAction description, workflow.

  Use when:
  When using action doSpyOnOtherPlayerAction or trying to understand it.
---

# doSpyOnOtherPlayerAction Action Documentation

# function path :`methods/actions/knowledge/doSpyOnOtherPlayerAction.ts`

# function doSpyOnOtherPlayerAction(params: TDoSpyOnOtherPlayerActionParams)

# TypeScript Types:

type TDoSpyOnOtherPlayerActionParams = Omit<TDoSpyOnOtherPlayerServiceParams, "sessionUserId"></T>

### Data Flow

function doSpyOnOtherPlayerService(params: TDoSpyOnOtherPlayerServiceParams) path:
methods/services/knowledge/doSpyOnOtherPlayerService.ts

TypeScript Types: export type TDoSpyOnOtherPlayerServiceParams = { sessionUserId: string playerId: number }

Database function doSpyOnOtherPlayer(params: TDoSpyOnOtherPlayerParams)

path: db/postgresMainDatabase/schemas/knowledge/doSpyOnOtherPlayer.ts TypeScript Types:

export type TDoSpyOnOtherPlayerParams = { userId: string playerId: number otherPlayerId: string knowledgeTypeId: number
}

export type TDoSpyOnOtherPlayer = { status: boolean message: string }

PostgreSQL Database "schema": "knowledge" "method": "do_spy_on_other_player" You have more information in mcp game-db
