---
name: ai-useFetchAllAbilities-description
description: |
  Hook useFetchAllAbilities description, workflow.

  Use when:
  When using hook useFetchAllAbilities or trying to understand it.
---

# useFetchAllAbilities hook Documentation

# function path :`methods/hooks/attributes/core/useFetchAllAbilities.ts`

# function useFetchAllAbilities( params: TAllAbilitiesParams)

# Jotai atom name: const allAbilitiesAtom = atom<TAllAbilitiesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/attributes/rpc/get-all-abilities/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TAllAbilitiesParams>

# function getAllAbilitiesServer( params: TAllAbilitiesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/attributes/core/getAllAbilitiesServer.ts`
# TypeScript Types:

type TResult = {
  raw: TAllAbilities[]
  byKey: TAllAbilitiesRecordById
  apiPath: string
  atomName: string
}

# function getAllAbilities(params: TAllAbilitiesParams)
# path: `db/postgresMainDatabase/schemas/attributes/allAbilities.ts`
# TypeScript Types:

export type TAllAbilitiesParams = {
  playerId: number
}

export type TAllAbilities = {
  id: number
  name: string
  description: string
  image: string
  value: number
}

export type TAllAbilitiesRecordById = Record<string, TAllAbilities>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutateAllAbilities.ts`
# function useMutateAllAbilities( params: TAllAbilitiesParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_all_abilities"
You have more information in mcp `game-db`
```
