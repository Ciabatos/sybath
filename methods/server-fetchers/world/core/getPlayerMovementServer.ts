// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import type { TPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import type { TPlayerMovementParams } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import type { TPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerMovement"

export async function getPlayerMovementServer(params: TPlayerMovementParams): Promise<{
  raw: TPlayerMovement[]
  byKey: TPlayerMovementRecordByXY
  apiPath: string
  atomName: string
}> {
  const getPlayerMovementData = await getPlayerMovement(params)

  const data = getPlayerMovementData
    ? (arrayToObjectKey(["x", "y"], getPlayerMovementData) as TPlayerMovementRecordByXY)
    : {}

  return {
    raw: getPlayerMovementData,
    byKey: data,
    apiPath: `/api/world/rpc/get-player-movement/${params.playerId}`,
    atomName: `playerMovementAtom`,
  }
}
