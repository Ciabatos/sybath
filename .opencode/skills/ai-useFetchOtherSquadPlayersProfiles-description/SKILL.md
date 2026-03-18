---
name: ai-useFetchOtherSquadPlayersProfiles-description
description: |
  Hook useFetchOtherSquadPlayersProfiles description, workflow.

  Use when:
  When using hook useFetchOtherSquadPlayersProfiles or trying to understand it.
---



# useFetchOtherSquadPlayersProfiles hook Documentation
# function path :`methods/hooks/squad/core/useFetchOtherSquadPlayersProfiles.ts` 
# function useFetchOtherSquadPlayersProfiles( params: TOtherSquadPlayersProfilesParams)
# Jotai atom name: const otherSquadPlayersProfilesAtom = atom<TOtherSquadPlayersProfilesRecordByOtherPlayerId>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/squad/rpc/get-other-squad-players-profiles/[playerId]/[squadId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  squadId: z.coerce.number(),
}) satisfies z.ZodType<TOtherSquadPlayersProfilesParams>

# function getOtherSquadPlayersProfilesServer( params: TOtherSquadPlayersProfilesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/squad/core/getOtherSquadPlayersProfilesServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TOtherSquadPlayersProfiles[]
  byKey: TOtherSquadPlayersProfilesRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

# function getOtherSquadPlayersProfiles(params: TOtherSquadPlayersProfilesParams)
# path: `db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles.ts` 
# TypeScript Types:

export type TOtherSquadPlayersProfilesParams = {
  playerId: number
  squadId: number
}

export type TOtherSquadPlayersProfiles = {
  otherPlayerId: string
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TOtherSquadPlayersProfilesRecordByOtherPlayerId = Record<string, TOtherSquadPlayersProfiles>

Hook for mutate data using SWR
# function path :`methods/hooks/squad/core/useMutateOtherSquadPlayersProfiles.ts` 
# function useMutateOtherSquadPlayersProfiles( params: TOtherSquadPlayersProfilesParams)

#### PostgreSQL Database
# "schema": "squad"
# "method": "get_other_squad_players_profiles"
You have more information in mcp `game-db`
```