// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getGetActivePlayerVisionPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"
import type { TGetActivePlayerVisionPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"
import type { TGetActivePlayerVisionPlayersPositionsParams } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"
import type { TGetActivePlayerVisionPlayersPositionsRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"

export async function getGetActivePlayerVisionPlayersPositionsServer(params: TGetActivePlayerVisionPlayersPositionsParams): Promise<{
  raw: TGetActivePlayerVisionPlayersPositions[]
  byKey: TGetActivePlayerVisionPlayersPositionsRecordByXY
  apiPath: string
}> {
  const getGetActivePlayerVisionPlayersPositionsData = await getGetActivePlayerVisionPlayersPositions(params)

  const data = getGetActivePlayerVisionPlayersPositionsData ? (arrayToObjectKey(["x", "y"], getGetActivePlayerVisionPlayersPositionsData) as TGetActivePlayerVisionPlayersPositionsRecordByXY) : {}

  return { raw: getGetActivePlayerVisionPlayersPositionsData, byKey: data, apiPath: `/api/world/rpc/get-active-player-vision-players-positions/${params.mapId}/${params.playerId}` }
}
