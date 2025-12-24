// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerMovementParams } from "@/db/postgresMainDatabase/schemas/world/playerMovement" 
import type { TPlayerMovementRecordByXY,TPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { fetchPlayerMovement } from "@/methods/services/world/fetchPlayerMovement"

type TResult = {
  raw: TPlayerMovement[]
  byKey: TPlayerMovementRecordByXY
  apiPath: string
  atomName: string
}

export async function getPlayerMovementServer( params: TPlayerMovementParams): Promise<TResult> {
  const { record } = await fetchPlayerMovement(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `api/world/rpc/get-player-movement/${params.playerId}`,
    atomName: `playerMovementAtom`,
  }
}

