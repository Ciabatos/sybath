---
name: ai-doSquadInviteAction-description
description: |
  Action doSquadInviteAction description, workflow.

  Use when:
  When using action doSquadInviteAction or trying to understand it.
---

# doSquadInviteAction Action Documentation

# function path :`methods/actions/squad/doSquadInviteAction.ts`

# function doSquadInviteAction(params: TDoSquadInviteActionParams)

# TypeScript Types:

type TDoSquadInviteActionParams = Omit<TDoSquadInviteServiceParams, "sessionUserId"></T>

### Data Flow

function doSquadInviteService(params: TDoSquadInviteServiceParams) path: methods/services/squad/doSquadInviteService.ts

TypeScript Types: export type TDoSquadInviteServiceParams = { sessionUserId: string playerId: number }

Database function doSquadInvite(params: TDoSquadInviteParams)

path: db/postgresMainDatabase/schemas/squad/doSquadInvite.ts TypeScript Types:

export type TDoSquadInviteParams = { userId: string playerId: number invitedPlayerId: string inviteType: number
squadRole: number }

export type TDoSquadInvite = { status: boolean message: string }

PostgreSQL Database "schema": "squad" "method": "do_squad_invite" You have more information in mcp game-db
