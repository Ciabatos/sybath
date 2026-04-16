---
name: ai-doSquadCreateAction-description
description: |
  Action doSquadCreateAction description, workflow.

  Use when:
  When using action doSquadCreateAction or trying to understand it.
---

# doSquadCreateAction Action Documentation

# function path :`methods/actions/squad/doSquadCreateAction.ts`

# function doSquadCreateAction(params: TDoSquadCreateActionParams)

# TypeScript Types:

type TDoSquadCreateActionParams = Omit<TDoSquadCreateServiceParams, "sessionUserId"></T>

### Data Flow

```
# function doSquadCreateService(params: TDoSquadCreateServiceParams)
path: `methods/services/squad/doSquadCreateService.ts`
# TypeScript Types:

export type TDoSquadCreateServiceParams = {
sessionUserId: number
playerId: number
}


 Database function doSquadCreate(params: TDoSquadCreateParams)
# path: `db/postgresMainDatabase/schemas/squad/doSquadCreate.ts`
# TypeScript Types:

export type TDoSquadCreateParams = {
  playerId: number
}

export type TDoSquadCreate = {
  status: boolean
  message: string
}

#### PostgreSQL Database
# "schema": "squad"
# "method": "do_squad_create"
You have more information in mcp `game-db`
```

Note: doSquadCreateAction is a Next.js Server Action A Next.js Server Action is a function that: Runs on the server Can
be called directly from a React component Is typically triggered by form submissions or user interactions Eliminates the
need for manual API endpoints
