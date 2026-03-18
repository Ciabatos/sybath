---
name: ai-useFetchAttributesSkills-description
description: |
  Hook useFetchAttributesSkills description, workflow.

  Use when:
  When using hook useFetchAttributesSkills or trying to understand it.
---



# useFetchAttributesSkills hook Documentation
# function path :`methods/hooks/attributes/core/useFetchAttributesSkills.ts` 
# function function useFetchAttributesSkills()
# Jotai atom name: const skillsAtom = atom<TAttributesSkillsRecordById>({})


### Data Flow
```
# function GET(request: NextRequest)
# path: `app/api/attributes/skills/route.ts` 


# function fetchAttributesSkillsService(options?: { clientEtag?: string; forceFresh?: boolean }): Promise<TFetchResult> 
# path: `methods/services/attributes/fetchAttributesSkillsService.ts` 
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

# function getAttributesSkills()
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
# function path :`methods/hooks/attributes/core/useMutateAttributesSkills.ts` 
# function useMutateAttributesSkills()

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_skills"
You have more information in mcp `game-db`
```