---
name: ai-useFetchAllSkills-description
description: |
  Hook useFetchAllSkills description, workflow.

  Use when:
  When using hook useFetchAllSkills or trying to understand it.
---

# useFetchAllSkills hook Documentation

# function path :`methods/hooks/attributes/core/useFetchAllSkills.ts`

# function useFetchAllSkills( params: TAllSkillsParams)

# Jotai atom name: const allSkillsAtom = atom<TAllSkillsRecordById>({})

### Data Flow

```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/attributes/rpc/get-all-skills/[playerId]/route.ts`
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TAllSkillsParams>

# function getAllSkillsServer( params: TAllSkillsParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/attributes/core/getAllSkillsServer.ts`
# TypeScript Types:

type TResult = {
  raw: TAllSkills[]
  byKey: TAllSkillsRecordById
  apiPath: string
  atomName: string
}

# function getAllSkills(params: TAllSkillsParams)
# path: `db/postgresMainDatabase/schemas/attributes/allSkills.ts`
# TypeScript Types:

export type TAllSkillsParams = {
  playerId: number
}

export type TAllSkills = {
  id: number
  name: string
  description: string
  image: string
  value: number
}

export type TAllSkillsRecordById = Record<string, TAllSkills>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutateAllSkills.ts`
# function useMutateAllSkills( params: TAllSkillsParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_all_skills"
You have more information in mcp `game-db`
```
