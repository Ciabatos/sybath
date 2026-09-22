---
name: ai-doSquadLeaveAction-description
description: |
  Action doSquadLeaveAction description, workflow.

  Use when:
  When using action doSquadLeaveAction or trying to understand it.
---



# doSquadLeaveAction Action Documentation
# function path :`methods/actions/squad/doSquadLeaveAction.ts` 
# function doSquadLeaveAction(params: TDoSquadLeaveActionParams)
# TypeScript Types:
type TDoSquadLeaveActionParams = Omit<TDoSquadLeaveServiceParams, "sessionUserId"></T>

### Data Flow
function doSquadLeaveService(params: TDoSquadLeaveServiceParams)
path: methods/services/squad/doSquadLeaveService.ts

TypeScript Types:
export type TDoSquadLeaveServiceParams = {
sessionUserId: string
playerId: number
}

Database function doSquadLeave(params: TDoSquadLeaveParams)

path: db/postgresMainDatabase/schemas/squad/doSquadLeave.ts
TypeScript Types:

export type TDoSquadLeaveParams = {
userId: string
playerId: number
}

export type TDoSquadLeave = {
status: boolean
message: string
}

PostgreSQL Database
"schema": "squad"
"method": "do_squad_leave"
You have more information in mcp game-db