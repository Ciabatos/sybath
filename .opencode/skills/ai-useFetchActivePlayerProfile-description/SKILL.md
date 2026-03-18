---
name: ai-useFetchActivePlayerProfile-description
description: |
  Hook useFetchActivePlayerProfile description, workflow.

  Use when:
  When using hook useFetchActivePlayerProfile or trying to understand it.
---



# useFetchActivePlayerProfile hook Documentation
# function path :`methods/hooks/players/core/useFetchActivePlayerProfile.ts` 
# function useFetchActivePlayerProfile( params: TActivePlayerProfileParams)
# Jotai atom name: const activePlayerProfileAtom = atom<TActivePlayerProfileRecordByName>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/players/rpc/get-active-player-profile/[playerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TActivePlayerProfileParams>

# function getActivePlayerProfileServer( params: TActivePlayerProfileParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/players/core/getActivePlayerProfileServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TActivePlayerProfile[]
  byKey: TActivePlayerProfileRecordByName
  apiPath: string
  atomName: string
}

# function getActivePlayerProfile(params: TActivePlayerProfileParams)
# path: `db/postgresMainDatabase/schemas/players/activePlayerProfile.ts` 
# TypeScript Types:

export type TActivePlayerProfileParams = {
  playerId: number
}

export type TActivePlayerProfile = {
  name: string
  secondName: string
  nickname: string
  imageMap: string
  imagePortrait: string
}

export type TActivePlayerProfileRecordByName = Record<string, TActivePlayerProfile>

Hook for mutate data using SWR
# function path :`methods/hooks/players/core/useMutateActivePlayerProfile.ts` 
# function useMutateActivePlayerProfile( params: TActivePlayerProfileParams)

#### PostgreSQL Database
# "schema": "players"
# "method": "get_active_player_profile"
You have more information in mcp `game-db`
```