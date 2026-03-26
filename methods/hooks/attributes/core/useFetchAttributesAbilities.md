---
name: ai-useFetchAttributesAbilities-description
description: |
  Hook useFetchAttributesAbilities description, workflow.

  Use when:
  When using hook useFetchAttributesAbilities or trying to understand it.
---

# useFetchAttributesAbilities hook Documentation

# function path :`methods/hooks/attributes/core/useFetchAttributesAbilities.ts`

# function function useFetchAttributesAbilities()

# Jotai atom name: const abilitiesAtom = atom<TAttributesAbilitiesRecordById>({})

### Data Flow

```
# function GET(request: NextRequest)
# path: `app/api/attributes/abilities/route.ts`


# function fetchAttributesAbilitiesService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/attributes/fetchAttributesAbilitiesService.ts`
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

# function getAttributesAbilities()
# path: `db/postgresMainDatabase/schemas/attributes/abilities.ts`
# TypeScript Types:

export type TAttributesAbilitiesParams = {
  id: number
}

export type TAttributesAbilities = {
  id: number
  name?: string
  description?: string
  image: string
}

export type TAttributesAbilitiesRecordById = Record<string, TAttributesAbilities>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutateAttributesAbilities.ts`
# function useMutateAttributesAbilities()

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_abilities"
You have more information in mcp `game-db`
```
