---
name: ai-doSquadJoinAction-description
description: |
  Action doSquadJoinAction description, workflow.

  Use when:
  When using action doSquadJoinAction or trying to understand it.
---



# doSquadJoinAction Action Documentation
# function path :`methods/actions/squad/doSquadJoinAction.ts` 
# function doSquadJoinAction(params: TDoSquadJoinActionParams)
# TypeScript Types:
type TDoSquadJoinActionParams = Omit<TDoSquadJoinServiceParams, "sessionUserId"></T>

### Data Flow
function doSquadJoinService(params: TDoSquadJoinServiceParams)
path: methods/services/squad/doSquadJoinService.ts

TypeScript Types:
export type TDoSquadJoinServiceParams = {
sessionUserId: string
playerId: number
}

Database function doSquadJoin(params: TDoSquadJoinParams)

path: db/postgresMainDatabase/schemas/squad/doSquadJoin.ts
TypeScript Types:

export type TDoSquadJoinParams = {
userId: string
playerId: number
squadInviteId: number
}

export type TDoSquadJoin = {
status: boolean
message: string
}

PostgreSQL Database
"schema": "squad"
"method": "do_squad_join"
You have more information in mcp game-db