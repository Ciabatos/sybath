// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/getPlayerMovement"
import type { TGetPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/getPlayerMovement"
import type { TGetPlayerMovementParams } from "@/db/postgresMainDatabase/schemas/world/getPlayerMovement"
import type { TGetPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getPlayerMovement"

export async function getPlayerMovementServer(params: TGetPlayerMovementParams): Promise<{
  raw: TGetPlayerMovement[]
  byKey: TGetPlayerMovementRecordByXY
  apiPath: string
}> {
  const getPlayerMovementData = await getPlayerMovement(params)

  const data = getPlayerMovementData ? (arrayToObjectKey(["x", "y"], getPlayerMovementData) as TGetPlayerMovementRecordByXY) : {}

  return { raw: getPlayerMovementData, byKey: data, apiPath: `/api/world/rpc/get-player-movement/${params.playerId}` }
}
