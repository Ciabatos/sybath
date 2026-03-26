---
name: ai-useFetchPlayerPosition-description
description: |
  Hook useFetchPlayerPosition description, workflow.

  Use when:
  When using hook useFetchPlayerPosition or trying to understand it.
---

# useFetchPlayerPosition hook Documentation

# function path :`methods/hooks/world/core/useFetchPlayerPosition.ts`

# function useFetchPlayerPosition( params: TPlayerPositionParams)

# Jotai atom name: const playerPositionAtom = atom<TPlayerPositionRecordByXY>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/world/rpc/get-player-position/[mapId]/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerPositionParams>

# function getPlayerPositionServer( params: TPlayerPositionParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/world/core/getPlayerPositionServer.ts`
# TypeScript Types:

type TResult = {
  raw: TPlayerPosition[]
  byKey: TPlayerPositionRecordByXY
  apiPath: string
  atomName: string
}

# function getPlayerPosition(params: TPlayerPositionParams)
# path: `db/postgresMainDatabase/schemas/world/playerPosition.ts`
# TypeScript Types:

export type TPlayerPositionParams = {
  mapId: number
  playerId: number
}

export type TPlayerPosition = {
  x: number
  y: number
  imageMap: string
}

export type TPlayerPositionRecordByXY = Record<string, TPlayerPosition>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutatePlayerPosition.ts`
# function useMutatePlayerPosition( params: TPlayerPositionParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_player_position"
You have more information in mcp `game-db`
```
