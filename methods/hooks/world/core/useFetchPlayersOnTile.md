---
name: ai-useFetchPlayersOnTile-description
description: |
  Hook useFetchPlayersOnTile description, workflow.

  Use when:
  When using hook useFetchPlayersOnTile or trying to understand it.
---

# useFetchPlayersOnTile hook Documentation

# function path :`methods/hooks/world/core/useFetchPlayersOnTile.ts`

# function useFetchPlayersOnTile( params: TPlayersOnTileParams)

# Jotai atom name: const playersOnTileAtom = atom<TPlayersOnTileRecordByOtherPlayerId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/world/rpc/get-players-on-tile/[mapId]/[mapTileX]/[mapTileY]/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
  mapTileX: z.coerce.number(),
  mapTileY: z.coerce.number(),
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayersOnTileParams>

# function getPlayersOnTileServer( params: TPlayersOnTileParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/world/core/getPlayersOnTileServer.ts`
# TypeScript Types:

type TResult = {
  raw: TPlayersOnTile[]
  byKey: TPlayersOnTileRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

# function getPlayersOnTile(params: TPlayersOnTileParams)
# path: `db/postgresMainDatabase/schemas/world/playersOnTile.ts`
# TypeScript Types:

export type TPlayersOnTileParams = {
  mapId: number
  mapTileX: number
  mapTileY: number
  playerId: number
}

export type TPlayersOnTile = {
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imagePortrait: string
}

export type TPlayersOnTileRecordByOtherPlayerId = Record<string, TPlayersOnTile>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutatePlayersOnTile.ts`
# function useMutatePlayersOnTile( params: TPlayersOnTileParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_players_on_tile"
You have more information in mcp `game-db`
```
