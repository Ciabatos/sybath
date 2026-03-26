---
name: ai-useFetchPlayerAbilities-description
description: |
  Hook useFetchPlayerAbilities description, workflow.

  Use when:
  When using hook useFetchPlayerAbilities or trying to understand it.
---

# useFetchPlayerAbilities hook Documentation

# function path :`methods/hooks/attributes/core/useFetchPlayerAbilities.ts`

# function useFetchPlayerAbilities( params: TPlayerAbilitiesParams)

# Jotai atom name: const playerAbilitiesAtom = atom<TPlayerAbilitiesRecordByAbilityId>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/attributes/rpc/get-player-abilities/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerAbilitiesParams>

# function getPlayerAbilitiesServer( params: TPlayerAbilitiesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/attributes/core/getPlayerAbilitiesServer.ts`
# TypeScript Types:

type TResult = {
  raw: TPlayerAbilities[]
  byKey: TPlayerAbilitiesRecordByAbilityId
  apiPath: string
  atomName: string
}

# function getPlayerAbilities(params: TPlayerAbilitiesParams)
# path: `db/postgresMainDatabase/schemas/attributes/playerAbilities.ts`
# TypeScript Types:

export type TPlayerAbilitiesParams = {
  playerId: number
}

export type TPlayerAbilities = {
  abilityId: number
  value: number
  name: string
}

export type TPlayerAbilitiesRecordByAbilityId = Record<string, TPlayerAbilities>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutatePlayerAbilities.ts`
# function useMutatePlayerAbilities( params: TPlayerAbilitiesParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_player_abilities"
You have more information in mcp `game-db`
```
