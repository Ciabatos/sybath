---
name: ai-useFetchPlayerKnownPlayers-description
description: |
  Hook useFetchPlayerKnownPlayers description, workflow.

  Use when:
  When using hook useFetchPlayerKnownPlayers or trying to understand it.
---

# useFetchPlayerKnownPlayers hook Documentation

# function path :`methods/hooks/knowledge/core/useFetchPlayerKnownPlayers.ts`

# function useFetchPlayerKnownPlayers( params: TPlayerKnownPlayersParams)

# Jotai atom name: const playerKnownPlayersAtom = atom<TPlayerKnownPlayersRecordByOtherPlayerId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/knowledge/rpc/get-player-known-players/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerKnownPlayersParams>

# function getPlayerKnownPlayersServer( params: TPlayerKnownPlayersParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/knowledge/core/getPlayerKnownPlayersServer.ts`
# TypeScript Types:

type TResult = {
  raw: TPlayerKnownPlayers[]
  byKey: TPlayerKnownPlayersRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

# function getPlayerKnownPlayers(params: TPlayerKnownPlayersParams)
# path: `db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers.ts`
# TypeScript Types:

export type TPlayerKnownPlayersParams = {
  playerId: number
}

export type TPlayerKnownPlayers = {
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imagePortrait: string
  mapId: number
  x: number
  y: number
  imageMap: string
}

export type TPlayerKnownPlayersRecordByOtherPlayerId = Record<string, TPlayerKnownPlayers>

Hook for mutate data using SWR
# function path :`methods/hooks/knowledge/core/useMutatePlayerKnownPlayers.ts`
# function useMutatePlayerKnownPlayers( params: TPlayerKnownPlayersParams)

#### PostgreSQL Database
# "schema": "knowledge"
# "method": "get_player_known_players"
You have more information in mcp `game-db`
```
