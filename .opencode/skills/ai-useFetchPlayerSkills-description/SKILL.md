---
name: ai-useFetchPlayerSkills-description
description: |
  Hook useFetchPlayerSkills description, workflow.

  Use when:
  When using hook useFetchPlayerSkills or trying to understand it.
---



# useFetchPlayerSkills hook Documentation
# function path :`methods/hooks/attributes/core/useFetchPlayerSkills.ts` 
# function useFetchPlayerSkills( params: TPlayerSkillsParams)
# Jotai atom name: const playerSkillsAtom = atom<TPlayerSkillsRecordBySkillId>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/attributes/rpc/get-player-skills/[playerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
}) satisfies z.ZodType<TPlayerSkillsParams>

# function getPlayerSkillsServer( params: TPlayerSkillsParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/attributes/core/getPlayerSkillsServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TPlayerSkills[]
  byKey: TPlayerSkillsRecordBySkillId
  apiPath: string
  atomName: string
}

# function getPlayerSkills(params: TPlayerSkillsParams)
# path: `db/postgresMainDatabase/schemas/attributes/playerSkills.ts` 
# TypeScript Types:

export type TPlayerSkillsParams = {
  playerId: number
}

export type TPlayerSkills = {
  skillId: number
  value: number
  name: string
}

export type TPlayerSkillsRecordBySkillId = Record<string, TPlayerSkills>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutatePlayerSkills.ts` 
# function useMutatePlayerSkills( params: TPlayerSkillsParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_player_skills"
You have more information in mcp `game-db`
```