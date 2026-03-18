---
name: ai-useFetchPlayerCity-description
description: |
  Hook useFetchPlayerCity description, workflow.

  Use when:
  When using hook useFetchPlayerCity or trying to understand it.
---



# useFetchPlayerCity hook Documentation
# function path :`methods/hooks/cities/core/useFetchPlayerCity.ts` 
# function useFetchPlayerCity( params: TPlayerCityParams)
# Jotai atom name: const playerCityAtom = atom<TPlayerCityRecordByCityId>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/cities/rpc/get-player-city/[playerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerCityParams>

# function getPlayerCityServer( params: TPlayerCityParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/cities/core/getPlayerCityServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TPlayerCity[]
  byKey: TPlayerCityRecordByCityId
  apiPath: string
  atomName: string
}

# function getPlayerCity(params: TPlayerCityParams)
# path: `db/postgresMainDatabase/schemas/cities/playerCity.ts` 
# TypeScript Types:

export type TPlayerCityParams = {
  playerId: number
}

export type TPlayerCity = {
  cityId: number
}

export type TPlayerCityRecordByCityId = Record<string, TPlayerCity>

Hook for mutate data using SWR
# function path :`methods/hooks/cities/core/useMutatePlayerCity.ts` 
# function useMutatePlayerCity( params: TPlayerCityParams)

#### PostgreSQL Database
# "schema": "cities"
# "method": "get_player_city"
You have more information in mcp `game-db`
```