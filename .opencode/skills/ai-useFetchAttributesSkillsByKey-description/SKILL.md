---
name: ai-useFetchAttributesSkillsByKey-description
description: |
  Hook useFetchAttributesSkillsByKey description, workflow.

  Use when:
  When using hook useFetchAttributesSkillsByKey or trying to understand it.
---



# useFetchAttributesSkillsByKey hook Documentation
# function path :`methods/hooks/attributes/core/useFetchAttributesSkillsByKey.ts` 
# function useFetchAttributesSkillsByKey( params: TAttributesSkillsParams )
# Jotai atom name: const skillsAtom = atom<TAttributesSkillsRecordById>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams })
# path: `app/api/attributes/skills/[id]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  id: z.coerce.number(),
}) satisfies z.ZodType<TAttributesSkillsParams>

# function fetchAttributesSkillsByKeyService(params: TAttributesSkillsParams,options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult>
# path: `methods/services/attributes/fetchAttributesSkillsByKeyService.ts` 
# TypeScript Types:

type TCacheRecord = {
  raw: TAttributesSkills[]
  byKey: TAttributesSkillsRecordById
  etag: string
}

type TFetchResult = {
  record?: TCacheRecord
  etag: string
  cacheHit: boolean
  etagMatched: boolean
}

# function function getAttributesSkillsByKey(params: TAttributesSkillsParams)
# path: `db/postgresMainDatabase/schemas/attributes/skills.ts` 
# TypeScript Types:

export type TAttributesSkillsParams = {
  id: number
}

export type TAttributesSkills = {
  id: number
  name?: string
  description?: string
  image: string
}

export type TAttributesSkillsRecordById = Record<string, TAttributesSkills>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutateAttributesSkillsByKey.ts` 
# function useMutateAttributesSkills( params: TAttributesSkillsParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_skills_by_key"
You have more information in mcp `game-db`
```