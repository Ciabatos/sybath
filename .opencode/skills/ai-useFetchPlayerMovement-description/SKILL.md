---
name: ai-useFetchPlayerMovement-description
description: |
  Hook useFetchPlayerMovement description, workflow.

  Use when:
  When using hook useFetchPlayerMovement or trying to understand it.
---



# useFetchPlayerMovement hook Documentation
# function path :`methods/hooks/world/core/useFetchPlayerMovement.ts` 
# function useFetchPlayerMovement( params: TPlayerMovementParams)
# Jotai atom name: const playerMovementAtom = atom<TPlayerMovementRecordByXY>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/world/rpc/get-player-movement/[playerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerMovementParams>

# function getPlayerMovementServer( params: TPlayerMovementParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/world/core/getPlayerMovementServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TPlayerMovement[]
  byKey: TPlayerMovementRecordByXY
  apiPath: string
  atomName: string
}

# function getPlayerMovement(params: TPlayerMovementParams)
# path: `db/postgresMainDatabase/schemas/world/playerMovement.ts` 
# TypeScript Types:

export type TPlayerMovementParams = {
  playerId: number
}

export type TPlayerMovement = {
  order: number
  moveCost: number
  mapId: number
  x: number
  y: number
  totalMoveCost: number
}

export type TPlayerMovementRecordByXY = Record<string, TPlayerMovement>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutatePlayerMovement.ts` 
# function useMutatePlayerMovement( params: TPlayerMovementParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_player_movement"
You have more information in mcp `game-db`
```