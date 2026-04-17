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

```
# function doSquadLeaveService(params: TDoSquadLeaveServiceParams)
path: `methods/services/squad/doSquadLeaveService.ts`
# TypeScript Types:

export type TDoSquadLeaveServiceParams = {
sessionUserId: number
playerId: number
}


 Database function doSquadLeave(params: TDoSquadLeaveParams)
# path: `db/postgresMainDatabase/schemas/squad/doSquadLeave.ts`
# TypeScript Types:

export type TDoSquadLeaveParams = {
  playerId: number
}

export type TDoSquadLeave = {
  status: boolean
  message: string
}

#### PostgreSQL Database
# "schema": "squad"
# "method": "do_squad_leave"
You have more information in mcp `game-db`
```

Note: doSquadLeaveAction is a Next.js Server Action A Next.js Server Action is a function that: Runs on the server Can
be called directly from a React component Is typically triggered by form submissions or user interactions Eliminates the
need for manual API endpoints
