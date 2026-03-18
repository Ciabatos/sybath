---
name: ai-useFetchKnownMapRegion-description
description: |
  Hook useFetchKnownMapRegion description, workflow.

  Use when:
  When using hook useFetchKnownMapRegion or trying to understand it.
---



# useFetchKnownMapRegion hook Documentation
# function path :`methods/hooks/world/core/useFetchKnownMapRegion.ts` 
# function useFetchKnownMapRegion( params: TKnownMapRegionParams)
# Jotai atom name: const knownMapRegionAtom = atom<TKnownMapRegionRecordByMapTileXMapTileY>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/world/rpc/get-known-map-region/[mapId]/[playerId]/[regionType]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  mapId: z.coerce.number(),
  playerId: z.coerce.number(),
  regionType: z.coerce.number(),
}) satisfies z.ZodType<TKnownMapRegionParams>

# function getKnownMapRegionServer( params: TKnownMapRegionParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/world/core/getKnownMapRegionServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TKnownMapRegion[]
  byKey: TKnownMapRegionRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

# function getKnownMapRegion(params: TKnownMapRegionParams)
# path: `db/postgresMainDatabase/schemas/world/knownMapRegion.ts` 
# TypeScript Types:

export type TKnownMapRegionParams = {
  mapId: number
  playerId: number
  regionType: number
}

export type TKnownMapRegion = {
  regionId: number
  mapId: number
  mapTileX: number
  mapTileY: number
  regionName: string
  imageFill: string
  imageOutline: string
}

export type TKnownMapRegionRecordByMapTileXMapTileY = Record<string, TKnownMapRegion>

Hook for mutate data using SWR
# function path :`methods/hooks/world/core/useMutateKnownMapRegion.ts` 
# function useMutateKnownMapRegion( params: TKnownMapRegionParams)

#### PostgreSQL Database
# "schema": "world"
# "method": "get_known_map_region"
You have more information in mcp `game-db`
```