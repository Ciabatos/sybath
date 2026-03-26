---
name: ai-useFetchOtherPlayerProfile-description
description: |
  Hook useFetchOtherPlayerProfile description, workflow.

  Use when:
  When using hook useFetchOtherPlayerProfile or trying to understand it.
---

# useFetchOtherPlayerProfile hook Documentation

# function path :`methods/hooks/players/core/useFetchOtherPlayerProfile.ts`

# function useFetchOtherPlayerProfile( params: TOtherPlayerProfileParams)

# Jotai atom name: const otherPlayerProfileAtom = atom<TOtherPlayerProfileRecordByName>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/players/rpc/get-other-player-profile/[playerId]/[otherPlayerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  otherPlayerId: z.coerce.string(),
}) satisfies z.ZodType<TOtherPlayerProfileParams>

# function getOtherPlayerProfileServer( params: TOtherPlayerProfileParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/players/core/getOtherPlayerProfileServer.ts`
# TypeScript Types:

type TResult = {
  raw: TOtherPlayerProfile[]
  byKey: TOtherPlayerProfileRecordByName
  apiPath: string
  atomName: string
}

# function getOtherPlayerProfile(params: TOtherPlayerProfileParams)
# path: `db/postgresMainDatabase/schemas/players/otherPlayerProfile.ts`
# TypeScript Types:

export type TOtherPlayerProfileParams = {
  playerId: number
  otherPlayerId: string
}

export type TOtherPlayerProfile = {
  name: string
  secondName: string
  nickname: string
  imagePortrait: string
}

export type TOtherPlayerProfileRecordByName = Record<string, TOtherPlayerProfile>

Hook for mutate data using SWR
# function path :`methods/hooks/players/core/useMutateOtherPlayerProfile.ts`
# function useMutateOtherPlayerProfile( params: TOtherPlayerProfileParams)

#### PostgreSQL Database
# "schema": "players"
# "method": "get_other_player_profile"
You have more information in mcp `game-db`
```
