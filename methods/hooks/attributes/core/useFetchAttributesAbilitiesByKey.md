---
name: ai-useFetchAttributesAbilitiesByKey-description
description: |
  Hook useFetchAttributesAbilitiesByKey description, workflow.

  Use when:
  When using hook useFetchAttributesAbilitiesByKey or trying to understand it.
---

# useFetchAttributesAbilitiesByKey hook Documentation

# function path :`methods/hooks/attributes/core/useFetchAttributesAbilitiesByKey.ts`

# function useFetchAttributesAbilitiesByKey( params: TAttributesAbilitiesParams )

# Jotai atom name: const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/attributes/abilities/[id]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TAttributesAbilitiesParams>

# function fetchAttributesAbilitiesByKeyService(params: TAttributesAbilitiesParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/attributes/fetchAttributesAbilitiesByKeyService.ts`
# TypeScript Types:

type TCacheRecord = {
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getAttributesAbilitiesByKey(params: TAttributesAbilitiesParams)
# path: `db/postgresMainDatabase/schemas/attributes/abilities.ts`
# TypeScript Types:

export type TAttributesAbilitiesParams = {
  id: number
}

export type TAttributesAbilities = {
  id: number
  name: string
  description: string
  image: string
}

export type TAttributesAbilitiesRecordById = Record<string, TAttributesAbilities>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutateAttributesAbilitiesByKey.ts`
# function useMutateAttributesAbilities( params: TAttributesAbilitiesParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_abilities_by_key"
You have more information in mcp `game-db`
```
