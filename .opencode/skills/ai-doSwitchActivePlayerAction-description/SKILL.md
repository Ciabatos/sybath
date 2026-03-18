---
name: ai-doSwitchActivePlayerAction-description
description: |
  Action doSwitchActivePlayerAction description, workflow.

  Use when:
  When using action doSwitchActivePlayerAction or trying to understand it.
---



# doSwitchActivePlayerAction Action Documentation
# function path :`methods/actions/players/doSwitchActivePlayerAction.ts` 
# function doSwitchActivePlayerAction(params: TDoSwitchActivePlayerActionParams)
# TypeScript Types:
type TDoSwitchActivePlayerActionParams = Omit<TDoSwitchActivePlayerServiceParams, "sessionUserId"></T>

### Data Flow
```
# function doSwitchActivePlayerService(params: TDoSwitchActivePlayerServiceParams)
path: `methods/services/players/doSwitchActivePlayerService.ts` 
# TypeScript Types:

export type TDoSwitchActivePlayerServiceParams = {
sessionUserId: number
playerId: number
}


 Database function doSwitchActivePlayer(params: TDoSwitchActivePlayerParams) 
# path: `db/postgresMainDatabase/schemas/players/doSwitchActivePlayer.ts` 
# TypeScript Types:

export type TDoSwitchActivePlayerParams = {
  playerId: number
  switchToPlayerId: number
}

export type TDoSwitchActivePlayer = {
  status: boolean
  message: string
}

#### PostgreSQL Database
# "schema": "players"
# "method": "do_switch_active_player"
You have more information in mcp `game-db`
```

Note: doSwitchActivePlayerAction is a Next.js Server Action
A Next.js Server Action is a function that:
Runs on the server
Can be called directly from a React component
Is typically triggered by form submissions or user interactions
Eliminates the need for manual API endpoints