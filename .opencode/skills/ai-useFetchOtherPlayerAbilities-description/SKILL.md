---
name: ai-useFetchOtherPlayerAbilities-description
description: |
  Hook useFetchOtherPlayerAbilities description, workflow.

  Use when:
  When using hook useFetchOtherPlayerAbilities or trying to understand it.
---



# useFetchOtherPlayerAbilities hook Documentation
# function path :`methods/hooks/attributes/core/useFetchOtherPlayerAbilities.ts` 
# function useFetchOtherPlayerAbilities( params: TOtherPlayerAbilitiesParams)
# Jotai atom name: const otherPlayerAbilitiesAtom = atom<TOtherPlayerAbilitiesRecordByAbilityId>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/attributes/rpc/get-other-player-abilities/[playerId]/[otherPlayerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  otherPlayerId: z.coerce.string(),
}) satisfies z.ZodType<TOtherPlayerAbilitiesParams>

# function getOtherPlayerAbilitiesServer( params: TOtherPlayerAbilitiesParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/attributes/core/getOtherPlayerAbilitiesServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TOtherPlayerAbilities[]
  byKey: TOtherPlayerAbilitiesRecordByAbilityId
  apiPath: string
  atomName: string
}

# function getOtherPlayerAbilities(params: TOtherPlayerAbilitiesParams)
# path: `db/postgresMainDatabase/schemas/attributes/otherPlayerAbilities.ts` 
# TypeScript Types:

export type TOtherPlayerAbilitiesParams = {
  playerId: number
  otherPlayerId: string
}

export type TOtherPlayerAbilities = {
  abilityId: number
  value: number
  name: string
}

export type TOtherPlayerAbilitiesRecordByAbilityId = Record<string, TOtherPlayerAbilities>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutateOtherPlayerAbilities.ts` 
# function useMutateOtherPlayerAbilities( params: TOtherPlayerAbilitiesParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_other_player_abilities"
You have more information in mcp `game-db`
```