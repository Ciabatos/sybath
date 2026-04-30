---
name: ai-useFetchPlayerEnergy-description
description: |
  Hook useFetchPlayerEnergy description, workflow.

  Use when:
  When using hook useFetchPlayerEnergy or trying to understand it.
---

# useFetchPlayerEnergy hook Documentation

# function path :`methods/hooks/attributes/core/useFetchPlayerEnergy.ts`

# function useFetchPlayerEnergy( params: TPlayerEnergyParams)

# Jotai atom name: const playerEnergyAtom = atom<TPlayerEnergyRecordByLastRegeneratedAt>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/attributes/rpc/get-player-energy/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerEnergyParams>

# function getPlayerEnergyServer( params: TPlayerEnergyParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/attributes/core/getPlayerEnergyServer.ts`
# TypeScript Types:

type TResult = {
  raw: TPlayerEnergy[]
  byKey: TPlayerEnergyRecordByLastRegeneratedAt
  apiPath: string
  atomName: string
}

# function getPlayerEnergy(params: TPlayerEnergyParams)
# path: `db/postgresMainDatabase/schemas/attributes/playerEnergy.ts`
# TypeScript Types:

export type TPlayerEnergyParams = {
  playerId: number
}


export type TPlayerEnergy = {
  currentEnergy: number
  maxEnergy: number
  lastRegeneratedAt: string
}

export type TPlayerEnergyRecordByLastRegeneratedAt = Record<string, TPlayerEnergy>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutatePlayerEnergy.ts`
# function useMutatePlayerEnergy( params: TPlayerEnergyParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_player_energy"
You have more information in mcp `game-db`
```
