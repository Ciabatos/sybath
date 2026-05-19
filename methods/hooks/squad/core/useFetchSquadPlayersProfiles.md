---
name: ai-useFetchSquadPlayersProfiles-description
description: |
  Hook useFetchSquadPlayersProfiles description, workflow.

  Use when:
  When using hook useFetchSquadPlayersProfiles or trying to understand it.
---

# useFetchSquadPlayersProfiles hook Documentation

# function path :`methods/hooks/squad/core/useFetchSquadPlayersProfiles.ts`

# function useFetchSquadPlayersProfiles( params: TSquadPlayersProfilesParams)

# Jotai atom name: const squadPlayersProfilesAtom = atom<TSquadPlayersProfilesRecordByOtherPlayerId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/squad/rpc/get-squad-players-profiles/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TSquadPlayersProfilesParams>

# function getSquadPlayersProfilesServer( params: TSquadPlayersProfilesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/squad/core/getSquadPlayersProfilesServer.ts`
# TypeScript Types:

type TResult = {
  raw: TSquadPlayersProfiles[]
  byKey: TSquadPlayersProfilesRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

# function getSquadPlayersProfiles(params: TSquadPlayersProfilesParams)
# path: `db/postgresMainDatabase/schemas/squad/squadPlayersProfiles.ts`
# TypeScript Types:

export type TSquadPlayersProfilesParams = {
  playerId: number
}


export type TSquadPlayersProfiles = {
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TSquadPlayersProfilesRecordByOtherPlayerId = Record<string, TSquadPlayersProfiles>

Hook for mutate data using SWR
# function path :`methods/hooks/squad/core/useMutateSquadPlayersProfiles.ts`
# function useMutateSquadPlayersProfiles( params: TSquadPlayersProfilesParams)

#### PostgreSQL Database
# "schema": "squad"
# "method": "get_squad_players_profiles"
You have more information in mcp `game-db`
```
