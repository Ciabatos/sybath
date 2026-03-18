---
name: ai-useFetchActivePlayerSwitchProfiles-description
description: |
  Hook useFetchActivePlayerSwitchProfiles description, workflow.

  Use when:
  When using hook useFetchActivePlayerSwitchProfiles or trying to understand it.
---



# useFetchActivePlayerSwitchProfiles hook Documentation
# function path :`methods/hooks/players/core/useFetchActivePlayerSwitchProfiles.ts` 
# function useFetchActivePlayerSwitchProfiles( params: TActivePlayerSwitchProfilesParams)
# Jotai atom name: const activePlayerSwitchProfilesAtom = atom<TActivePlayerSwitchProfilesRecordById>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/players/rpc/get-active-player-switch-profiles/[playerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TActivePlayerSwitchProfilesParams>

# function getActivePlayerSwitchProfilesServer( params: TActivePlayerSwitchProfilesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/players/core/getActivePlayerSwitchProfilesServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TActivePlayerSwitchProfiles[]
  byKey: TActivePlayerSwitchProfilesRecordById
  apiPath: string
  atomName: string
}

# function getActivePlayerSwitchProfiles(params: TActivePlayerSwitchProfilesParams)
# path: `db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles.ts` 
# TypeScript Types:

export type TActivePlayerSwitchProfilesParams = {
  playerId: number
}

export type TActivePlayerSwitchProfiles = {
  id: number
  name: string
  secondName: string
  nickname: string
  imagePortrait: string
}

export type TActivePlayerSwitchProfilesRecordById = Record<string, TActivePlayerSwitchProfiles>

Hook for mutate data using SWR
# function path :`methods/hooks/players/core/useMutateActivePlayerSwitchProfiles.ts` 
# function useMutateActivePlayerSwitchProfiles( params: TActivePlayerSwitchProfilesParams)

#### PostgreSQL Database
# "schema": "players"
# "method": "get_active_player_switch_profiles"
You have more information in mcp `game-db`
```