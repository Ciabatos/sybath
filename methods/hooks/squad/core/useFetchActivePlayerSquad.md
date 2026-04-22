---
name: ai-useFetchActivePlayerSquad-description
description: |
  Hook useFetchActivePlayerSquad description, workflow.

  Use when:
  When using hook useFetchActivePlayerSquad or trying to understand it.
---

# useFetchActivePlayerSquad hook Documentation

# function path :`methods/hooks/squad/core/useFetchActivePlayerSquad.ts`

# function useFetchActivePlayerSquad( params: TActivePlayerSquadParams)

# Jotai atom name: const activePlayerSquadAtom = atom<TActivePlayerSquadRecordBySquadId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/squad/rpc/get-active-player-squad/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TActivePlayerSquadParams>

# function getActivePlayerSquadServer( params: TActivePlayerSquadParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/squad/core/getActivePlayerSquadServer.ts`
# TypeScript Types:

type TResult = {
  raw: TActivePlayerSquad[]
  byKey: TActivePlayerSquadRecordBySquadId
  apiPath: string
  atomName: string
}

# function getActivePlayerSquad(params: TActivePlayerSquadParams)
# path: `db/postgresMainDatabase/schemas/squad/activePlayerSquad.ts`
# TypeScript Types:

export type TActivePlayerSquadParams = {
  playerId: number
}


export type TActivePlayerSquad = {
  squadId: number
  squadName: string
  squadImagePortrait: string
}

export type TActivePlayerSquadRecordBySquadId = Record<string, TActivePlayerSquad>

Hook for mutate data using SWR
# function path :`methods/hooks/squad/core/useMutateActivePlayerSquad.ts`
# function useMutateActivePlayerSquad( params: TActivePlayerSquadParams)

#### PostgreSQL Database
# "schema": "squad"
# "method": "get_active_player_squad"
You have more information in mcp `game-db`
```
