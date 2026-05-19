---
name: ai-useFetchSquad-description
description: |
  Hook useFetchSquad description, workflow.

  Use when:
  When using hook useFetchSquad or trying to understand it.
---

# useFetchSquad hook Documentation

# function path :`methods/hooks/squad/core/useFetchSquad.ts`

# function useFetchSquad( params: TSquadParams)

# Jotai atom name: const squadAtom = atom<TSquadRecordBySquadId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/squad/rpc/get-squad/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TSquadParams>

# function getSquadServer( params: TSquadParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/squad/core/getSquadServer.ts`
# TypeScript Types:

type TResult = {
  raw: TSquad[]
  byKey: TSquadRecordBySquadId
  apiPath: string
  atomName: string
}

# function getSquad(params: TSquadParams)
# path: `db/postgresMainDatabase/schemas/squad/squad.ts`
# TypeScript Types:

export type TSquadParams = {
  playerId: number
}


export type TSquad = {
  squadId: number
  squadName: string
  squadImagePortrait: string
}

export type TSquadRecordBySquadId = Record<string, TSquad>

Hook for mutate data using SWR
# function path :`methods/hooks/squad/core/useMutateSquad.ts`
# function useMutateSquad( params: TSquadParams)

#### PostgreSQL Database
# "schema": "squad"
# "method": "get_squad"
You have more information in mcp `game-db`
```
