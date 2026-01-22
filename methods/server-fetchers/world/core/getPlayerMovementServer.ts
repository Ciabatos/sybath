// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerMovementParams } from "@/db/postgresMainDatabase/schemas/world/playerMovement" 
import type { TPlayerMovementRecordByXY,TPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { fetchPlayerMovementService } from "@/methods/services/world/fetchPlayerMovementService"

type TResult = {
  raw: TPlayerMovement[]
  byKey: TPlayerMovementRecordByXY
  apiPath: string
  atomName: string
}

export async function getPlayerMovementServer( params: TPlayerMovementParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchPlayerMovementService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/rpc/get-player-movement/${params.playerId}`,
    atomName: `playerMovementAtom`,
  }
}

