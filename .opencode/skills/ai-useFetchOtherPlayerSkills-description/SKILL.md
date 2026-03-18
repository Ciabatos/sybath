---
name: ai-useFetchOtherPlayerSkills-description
description: |
  Hook useFetchOtherPlayerSkills description, workflow.

  Use when:
  When using hook useFetchOtherPlayerSkills or trying to understand it.
---



# useFetchOtherPlayerSkills hook Documentation
# function path :`methods/hooks/attributes/core/useFetchOtherPlayerSkills.ts` 
# function useFetchOtherPlayerSkills( params: TOtherPlayerSkillsParams)
# Jotai atom name: const otherPlayerSkillsAtom = atom<TOtherPlayerSkillsRecordBySkillId>({})


### Data Flow
```
# function GET(request: NextRequest, { params }: { params: TApiParams } )
# path: `app/api/attributes/rpc/get-other-player-skills/[playerId]/[otherPlayerId]/route.ts` 
# TypeScript Types:
type TApiParams = Record<string, string>

const typeParamsSchema = z.object({
  playerId: z.coerce.number(),
  otherPlayerId: z.coerce.string(),
}) satisfies z.ZodType<TOtherPlayerSkillsParams>

# function getOtherPlayerSkillsServer( params: TOtherPlayerSkillsParams, options?: { forceFresh?: boolean },): Promise<TResult>
# path: `methods/server-fetchers/attributes/core/getOtherPlayerSkillsServer.ts` 
# TypeScript Types:

type TResult = {
  raw: TOtherPlayerSkills[]
  byKey: TOtherPlayerSkillsRecordBySkillId
  apiPath: string
  atomName: string
}

# function getOtherPlayerSkills(params: TOtherPlayerSkillsParams)
# path: `db/postgresMainDatabase/schemas/attributes/otherPlayerSkills.ts` 
# TypeScript Types:

export type TOtherPlayerSkillsParams = {
  playerId: number
  otherPlayerId: string
}

export type TOtherPlayerSkills = {
  skillId: number
  value: number
  name: string
}

export type TOtherPlayerSkillsRecordBySkillId = Record<string, TOtherPlayerSkills>

Hook for mutate data using SWR
# function path :`methods/hooks/attributes/core/useMutateOtherPlayerSkills.ts` 
# function useMutateOtherPlayerSkills( params: TOtherPlayerSkillsParams)

#### PostgreSQL Database
# "schema": "attributes"
# "method": "get_other_player_skills"
You have more information in mcp `game-db`
```