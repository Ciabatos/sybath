// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerVisionPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/getPlayerVisionPlayersPositions"
import type { TGetPlayerVisionPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/getPlayerVisionPlayersPositions"
import type { TGetPlayerVisionPlayersPositionsParams } from "@/db/postgresMainDatabase/schemas/world/getPlayerVisionPlayersPositions"
import type { TGetPlayerVisionPlayersPositionsRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getPlayerVisionPlayersPositions"

export async function getPlayerVisionPlayersPositionsServer(params: TGetPlayerVisionPlayersPositionsParams): Promise<{
  raw: TGetPlayerVisionPlayersPositions[]
  byKey: TGetPlayerVisionPlayersPositionsRecordByXY
  apiPath: string
}> {
  const getPlayerVisionPlayersPositionsData = await getPlayerVisionPlayersPositions(params)

  const data = getPlayerVisionPlayersPositionsData
    ? (arrayToObjectKey(["x", "y"], getPlayerVisionPlayersPositionsData) as TGetPlayerVisionPlayersPositionsRecordByXY)
    : {}

  return {
    raw: getPlayerVisionPlayersPositionsData,
    byKey: data,
    apiPath: `/api/world/rpc/get-player-vision-players-positions/${params.mapId}/${params.playerId}`,
  }
}
