---
name: ai-useFetchActivePlayerSquadPlayersProfiles-description
description: |
  Hook useFetchActivePlayerSquadPlayersProfiles description, workflow.

  Use when:
  When using hook useFetchActivePlayerSquadPlayersProfiles or trying to understand it.
---

# useFetchActivePlayerSquadPlayersProfiles hook Documentation

# function path :`methods/hooks/squad/core/useFetchActivePlayerSquadPlayersProfiles.ts`

# function useFetchActivePlayerSquadPlayersProfiles( params: TActivePlayerSquadPlayersProfilesParams)

# Jotai atom name: const activePlayerSquadPlayersProfilesAtom = atom<TActivePlayerSquadPlayersProfilesRecordByOtherPlayerId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/squad/rpc/get-active-player-squad-players-profiles/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TActivePlayerSquadPlayersProfilesParams>

# function getActivePlayerSquadPlayersProfilesServer( params: TActivePlayerSquadPlayersProfilesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/squad/core/getActivePlayerSquadPlayersProfilesServer.ts`
# TypeScript Types:

type TResult = {
  raw: TActivePlayerSquadPlayersProfiles[]
  byKey: TActivePlayerSquadPlayersProfilesRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

# function getActivePlayerSquadPlayersProfiles(params: TActivePlayerSquadPlayersProfilesParams)
# path: `db/postgresMainDatabase/schemas/squad/activePlayerSquadPlayersProfiles.ts`
# TypeScript Types:

export type TActivePlayerSquadPlayersProfilesParams = {
  playerId: number
}

export type TActivePlayerSquadPlayersProfiles = {
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TActivePlayerSquadPlayersProfilesRecordByOtherPlayerId = Record<string, TActivePlayerSquadPlayersProfiles>

Hook for mutate data using SWR
# function path :`methods/hooks/squad/core/useMutateActivePlayerSquadPlayersProfiles.ts`
# function useMutateActivePlayerSquadPlayersProfiles( params: TActivePlayerSquadPlayersProfilesParams)

#### PostgreSQL Database
# "schema": "squad"
# "method": "get_active_player_squad_players_profiles"
You have more information in mcp `game-db`
```
