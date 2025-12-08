// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getGetActivePlayerPosition } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"
import type { TGetActivePlayerPosition } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"
import type { TGetActivePlayerPositionParams } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"
import type { TGetActivePlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getActivePlayerPosition"

export async function getGetActivePlayerPositionServer(params: TGetActivePlayerPositionParams): Promise<{
  raw: TGetActivePlayerPosition[]
  byKey: TGetActivePlayerPositionRecordByXY
  apiPath: string
}> {
  const getGetActivePlayerPositionData = await getGetActivePlayerPosition(params)

  const data = getGetActivePlayerPositionData ? (arrayToObjectKey(["x", "y"], getGetActivePlayerPositionData) as TGetActivePlayerPositionRecordByXY) : {}

  return { raw: getGetActivePlayerPositionData, byKey: data, apiPath: `/api/world/rpc/get-active-player-position/${params.mapId}/${params.playerId}` }
}
