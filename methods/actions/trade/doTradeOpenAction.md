---
name: ai-doTradeOpenAction-description
description: |
  Action doTradeOpenAction description, workflow.

  Use when:
  When using action doTradeOpenAction or trying to understand it.
---

# doTradeOpenAction Action Documentation

# function path :`methods/actions/trade/doTradeOpenAction.ts`

# function doTradeOpenAction(params: TDoTradeOpenActionParams)

# TypeScript Types:

type TDoTradeOpenActionParams = Omit<TDoTradeOpenServiceParams, "sessionUserId"></T>

### Data Flow

function doTradeOpenService(params: TDoTradeOpenServiceParams) path: methods/services/trade/doTradeOpenService.ts

TypeScript Types: export type TDoTradeOpenServiceParams = { sessionUserId: string playerId: number }

Database function doTradeOpen(params: TDoTradeOpenParams)

path: db/postgresMainDatabase/schemas/trade/doTradeOpen.ts TypeScript Types:

export type TDoTradeOpenParams = { userId: string playerId: number invitedPlayerId: string }

export type TDoTradeOpen = { status: boolean message: string }

PostgreSQL Database "schema": "trade" "method": "do_trade_open" You have more information in mcp game-db
