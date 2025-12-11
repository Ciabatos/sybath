// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getActivePlayerVisionPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"
import type { TGetActivePlayerVisionPlayersPositions } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"
import type { TGetActivePlayerVisionPlayersPositionsParams } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"
import type { TGetActivePlayerVisionPlayersPositionsRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerVisionPlayersPositions"

export async function getActivePlayerVisionPlayersPositionsServer(
  params: TGetActivePlayerVisionPlayersPositionsParams,
): Promise<{
  raw: TGetActivePlayerVisionPlayersPositions[]
  byKey: TGetActivePlayerVisionPlayersPositionsRecordByXY
  apiPath: string
}> {
  const getActivePlayerVisionPlayersPositionsData = await getActivePlayerVisionPlayersPositions(params)

  const data = getActivePlayerVisionPlayersPositionsData
    ? (arrayToObjectKey(
        ["x", "y"],
        getActivePlayerVisionPlayersPositionsData,
      ) as TGetActivePlayerVisionPlayersPositionsRecordByXY)
    : {}

  return {
    raw: getActivePlayerVisionPlayersPositionsData,
    byKey: data,
    apiPath: `/api/world/rpc/get-active-player-vision-players-positions/${params.mapId}/${params.playerId}`,
  }
}
