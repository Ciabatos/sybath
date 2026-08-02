---
name: ai-useFetchTrades-description
description: |
  Hook useFetchTrades description, workflow.

  Use when:
  When using hook useFetchTrades or trying to understand it.
---

# useFetchTrades hook Documentation

# function path :`methods/hooks/trade/core/useFetchTrades.ts`

# function useFetchTrades( params: TTradesParams)

# Jotai atom name: const tradesAtom = atom<TTradesRecordByTradeId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/trade/rpc/get-trades/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TTradesParams>

# function getTradesServer( params: TTradesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/trade/core/getTradesServer.ts`
# TypeScript Types:

type TResult = {
  raw: TTrades[]
  byKey: TTradesRecordByTradeId
  apiPath: string
  atomName: string
}

# function getTrades(params: TTradesParams)
# path: `db/postgresMainDatabase/schemas/trade/trades.ts`
# TypeScript Types:

export type TTradesParams = {
  playerId: number
}


export type TTrades = {
  tradeId: number
  status: number
  createdAt: string
  updatedAt: string
  expiresAt: string
}

export type TTradesRecordByTradeId = Record<string, TTrades>

Hook for mutate data using SWR
# function path :`methods/hooks/trade/core/useMutateTrades.ts`
# function useMutateTrades( params: TTradesParams)

#### PostgreSQL Database
# "schema": "trade"
# "method": "get_trades"
You have more information in mcp `game-db`
```
