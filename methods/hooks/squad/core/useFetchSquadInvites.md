---
name: ai-useFetchSquadInvites-description
description: |
  Hook useFetchSquadInvites description, workflow.

  Use when:
  When using hook useFetchSquadInvites or trying to understand it.
---

# useFetchSquadInvites hook Documentation

# function path :`methods/hooks/squad/core/useFetchSquadInvites.ts`

# function useFetchSquadInvites( params: TSquadInvitesParams)

# Jotai atom name: const squadInvitesAtom = atom<TSquadInvitesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/squad/rpc/get-squad-invites/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TSquadInvitesParams>

# function getSquadInvitesServer( params: TSquadInvitesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/squad/core/getSquadInvitesServer.ts`
# TypeScript Types:

type TResult = {
  raw: TSquadInvites[]
  byKey: TSquadInvitesRecordById
  apiPath: string
  atomName: string
}

# function getSquadInvites(params: TSquadInvitesParams)
# path: `db/postgresMainDatabase/schemas/squad/squadInvites.ts`
# TypeScript Types:

export type TSquadInvitesParams = {
  playerId: number
}

export type TSquadInvites = {
  id: number
  description: string
  name: string
  nickname: string
  secondName: string
  createdAt: string
}

export type TSquadInvitesRecordById = Record<string, TSquadInvites>

Hook for mutate data using SWR
# function path :`methods/hooks/squad/core/useMutateSquadInvites.ts`
# function useMutateSquadInvites( params: TSquadInvitesParams)

#### PostgreSQL Database
# "schema": "squad"
# "method": "get_squad_invites"
You have more information in mcp `game-db`
```
