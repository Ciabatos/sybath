// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/getPlayerPosition"
import type { TGetPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/getPlayerPosition"
import type { TGetPlayerPositionParams } from "@/db/postgresMainDatabase/schemas/world/getPlayerPosition"
import type { TGetPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getPlayerPosition"

export async function getPlayerPositionServer(params: TGetPlayerPositionParams): Promise<{
  raw: TGetPlayerPosition[]
  byKey: TGetPlayerPositionRecordByXY
  apiPath: string
}> {
  const getPlayerPositionData = await getPlayerPosition(params)

  const data = getPlayerPositionData
    ? (arrayToObjectKey(["x", "y"], getPlayerPositionData) as TGetPlayerPositionRecordByXY)
    : {}

  return {
    raw: getPlayerPositionData,
    byKey: data,
    apiPath: `/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`,
  }
}
