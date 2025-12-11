// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getActivePlayerPosition } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"
import type { TGetActivePlayerPosition } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"
import type { TGetActivePlayerPositionParams } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"
import type { TGetActivePlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"

export async function getActivePlayerPositionServer(params: TGetActivePlayerPositionParams): Promise<{
  raw: TGetActivePlayerPosition[]
  byKey: TGetActivePlayerPositionRecordByXY
  apiPath: string
}> {
  const getActivePlayerPositionData = await getActivePlayerPosition(params)

  const data = getActivePlayerPositionData
    ? (arrayToObjectKey(["x", "y"], getActivePlayerPositionData) as TGetActivePlayerPositionRecordByXY)
    : {}

  return {
    raw: getActivePlayerPositionData,
    byKey: data,
    apiPath: `/api/world/rpc/get-active-player-position/${params.mapId}/${params.playerId}`,
  }
}
